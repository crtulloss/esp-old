// helper functions for autoencoder weight updates, threshold updates, detection

// TODO figure out RELU implementation
/*
void RELU(TYPE activations[layer1_dimension], TYPE dactivations[layer1_dimension], int size) {
    int i;
    for( i = 0; i < size; i++) {
        dactivations[i] = activations[i]*(1.0-activations[i]);
        activations[i] = 1.0/(1.0+exp(-activations[i]));
    }
}
*/

// updates threshold between spike and noise for a given time window
// scalar version
void thresh_update(TYPE in[],
                   int32_t num_windows,
                   int32_t window_size,
                   TYPE rate_spike,
                   TYPE rate_noise,
                   TYPE spike_weight,
                   TYPE mean_spike[],
                   TYPE mean_noise[],
                   TYPE thresh[],
                   int32_t indata_offset) {

    TYPE data;
    TYPE m_spike;
    TYPE m_noise;
    TYPE delta_spike;
    TYPE delta_noise;
    TYPE delta_spike_abs;
    TYPE delta_noise_abs;

    uint32_t window_offset;
    uint32_t total_offset;

    for (uint32_t window = 0; window < num_windows; window++) {
        
        window_offset = window * window_size;
        // modified from hw version to account for all input data being in one array
        total_offset = indata_offset + window_offset;

        for (uint32_t elec = 0; elec < window_size; elec++) {

            // acquire sample for this electrode
            // note that in current version, this data will be max-min for a time window
            data = a_read(in[total_offset + elec]);

            // acquire relevant means
            m_spike = a_read(mean_spike[window_offset + elec]);
            m_noise = a_read(mean_noise[window_offset + elec]);

            // calculate deltas
            delta_spike = data - m_spike;
            delta_noise = data - m_noise;

            // calculate absolute deltas
            if (delta_noise < 0) {
                delta_noise_abs = delta_noise * -1.0;
            }
            else {
                delta_noise_abs = delta_noise;
            }
            if (delta_spike < 0) {
                delta_spike_abs = delta_spike * -1.0;
            }
            else {
                delta_spike_abs = delta_spike;
            }

            // determine which mean the sample is closer to and update means
            if (delta_spike_abs < delta_noise_abs) {

                // spike cluster
                // update the mean
                m_spike = m_spike + delta_spike * rate_spike;
                mean_spike[window_offset + elec] = a_write(m_spike);
            }

            else {
                // noise cluster
                // update the mean
                m_noise = m_noise + delta_noise * rate_noise;
                mean_noise[window_offset + elec] = a_write(m_noise);
            }

            // update thresh
            thresh[window_offset + elec] = a_write(spike_weight * (m_spike + m_noise));

            // done with this electrode
        }
        // done with this window
    }
}

// updates threshold between spike and noise for a given time window
// vector version
void thresh_update_vector(TYPE in[],
                          int32_t num_windows,
                          int32_t window_size,
                          TYPE rate_spike,
                          TYPE rate_noise,
                          TYPE spike_weight,
                          TYPE mean_spike[],
                          TYPE mean_noise[],
                          TYPE thresh[],
                          int32_t indata_offset) {

    TYPE data;
    TYPE m_spike;
    TYPE m_noise;
    TYPE delta_spike;
    TYPE delta_noise;
    TYPE delta_spike_abs;
    TYPE delta_noise_abs;

    TYPE norm_spike;
    TYPE norm_noise;
    bool spike;

    uint32_t window_offset;
    uint32_t total_offset;

    for (uint32_t window = 0; window < num_windows; window++) {
        
        window_offset = window * window_size;
        // modified from hw version to account for all input data being in one array
        total_offset = indata_offset + window_offset;
        
        // reset norm for this window
        norm_spike = 0;
        norm_noise = 0;

        for (uint32_t elec = 0; elec < window_size; elec++) {

            // acquire sample for this electrode
            // note that in current version, this data will be max-min for a time window
            data = a_read(in[total_offset + elec]);

            // acquire relevant means
            m_spike = a_read(mean_spike[window_offset + elec]);
            m_noise = a_read(mean_noise[window_offset + elec]);

            // calculate deltas
            delta_spike = data - m_spike;
            delta_noise = data - m_noise;

            // calculate absolute deltas
            if (delta_noise < 0) {
                delta_noise_abs = delta_noise * -1.0;
            }
            else {
                delta_noise_abs = delta_noise;
            }
            if (delta_spike < 0) {
                delta_spike_abs = delta_spike * -1.0;
            }
            else {
                delta_spike_abs = delta_spike;
            }

            // update norms - Manhattan norm
            norm_spike = norm_spike + delta_spike_abs;
            norm_noise = norm_noise + delta_noise_abs;
            
            // done with this electrode
        }

        // determine which mean the sample is closer to and update means
        if (norm_spike < norm_noise) {
            spike = true;
        }

        else {
            spike = false;
        }


        // update the means appropriately
        for (uint32_t elec = 0; elec < window_size; elec++) {

            // acquire sample for this electrode
            // note that in current version, this data will be max-min for a time window
            data = a_read(in[total_offset + elec]);

            // acquire relevant means
            m_spike = a_read(mean_spike[window_offset + elec]);
            m_noise = a_read(mean_noise[window_offset + elec]);

            // calculate deltas
            delta_spike = data - m_spike;
            delta_noise = data - m_noise;

            if (spike) {
                // spike cluster
                // update the mean
                m_spike = m_spike + delta_spike * rate_spike;
                mean_spike[window_offset + elec] = a_write(m_spike);
            }
            else {
                // noise cluster
                // update the mean
                m_noise = m_noise + delta_noise * rate_noise;
                mean_noise[window_offset + elec] = a_write(m_noise);
            }

            // update thresh
            thresh[window_offset + elec] = a_write(spike_weight * (m_spike + m_noise));

            // done with this electrode
        }

        // done with this window
    }
}

// relavancy detection used to choose input data
void relevant(TYPE in[],
              int32_t total_tsamps,
              int32_t num_windows,
              int32_t window_size,
              bool flag[],
              TYPE thresh,
              int32_t indata_offset) {

    TYPE data;

    uint32_t num_electrodes = num_windows*window_size;

    // TODO fix this to not use an arbitarily sized array
/*
    TYPE max[num_electrodes];
    TYPE min[num_electrodes];
*/
    // sized using fixed magic numbers based on max accel config
    const uint32_t const_num_electrodes = CONST_NUM_WINDOWS*CONST_WINDOW_SIZE;
    TYPE max[const_num_electrodes];
    TYPE min[const_num_electrodes];

    uint32_t samp_offset;
    uint32_t window_offset;
    uint32_t total_offset;

    // first, process all time samples to find max and min for each elec
    for (uint32_t samp = 0; samp < total_tsamps; samp++) {

        samp_offset = samp * num_electrodes;
        
        for (uint32_t window = 0; window < num_windows; window++) {

            window_offset = window * window_size;
            // modified from hw version to account for all input data being in one array
            total_offset = indata_offset + samp_offset + window_offset;

            for (uint32_t elec = 0; elec < window_size; elec++) {

                // on first sample for each elec, reset the max and min
                if (samp == 0) {
                    max[window_offset + elec] = a_write(0.0);
                    min[window_offset + elec] = a_write(0.0);
                }

                data = a_read(in[total_offset + elec]);

                // compare data for this sample with existing max and min
                if (data > a_read(max[window_offset + elec])) {
                    max[window_offset + elec] = a_write(data);
                }
                else if (data < a_read(min[window_offset + elec])) {
                    min[window_offset + elec] = a_write(data);
                }

                // done with this sample for this electrode
            }
            // done with this sample for all electrodes in this window
        }
        // done with this samples for all electrodes in all windows
    }

    // now post-process each window to check max and min
    for (uint32_t window = 0; window < num_windows; window++) {

        window_offset = window * window_size;

        // reset flag
        flag[window] = false;

        // check max and min for each elec
        for (uint32_t elec = 0; elec < window_size; elec++) {
            if ((a_read(max[window_offset + elec]) - a_read(min[window_offset + elec])) > thresh) {
                // flag the window
                flag[window] = true;
                // don't need to check other electrodes in this window
                cout << "min " << window << "elec " << elec << ": max " << a_read(max[window_offset + elec])
                    << "\tmin: " << a_read(min[window_offset + elec]) << "\n";
                break;
            }
            /*
            else {
                flag[window] = true;
                break;
            }
            */
        }
        // done with this window
    }

    // done
}

// backprop function used in computational kernel
void backprop(TYPE in[],
              TYPE plm_out[],
              bool do_relu,
              TYPE learning_rate,
              TYPE learning_rate_scaled,
              int32_t tsamps_perbatch,
              int32_t num_windows,
              int32_t iters_perbatch,
              int32_t input_dimension,
              int32_t layer1_dimension,
              int32_t output_dimension,
              int32_t W1_size,
              int32_t W2_size,
              int32_t B1_size,
              int32_t B2_size,
              int32_t batch,
              bool flag[],
              int32_t indata_offset) {

    // single-tsamp data for all electrodes - size e.g. 4 * 32 = 256
    uint32_t num_electrodes = num_windows*input_dimension;
    
    // TODO FLATTEN THIS?
/*
    TYPE elecdata[num_electrodes];
*/
    const uint32_t const_num_electrodes = CONST_NUM_WINDOWS*CONST_WINDOW_SIZE;
    TYPE elecdata[const_num_electrodes];

    // some offsets useful for indexing
    uint32_t samp_offset;
    uint32_t window_offset_dW1;
    uint32_t window_offset_dW2;
    uint32_t window_offset_weights2;
    uint32_t window_offset_weights1;
    uint32_t window_offset_output;
    uint32_t window_offset_layer1;
    uint32_t window_offset_input;
#ifdef do_bias
    uint32_t window_offset_biases2;
    uint32_t window_offset_biases1;
#endif

    // PLM access offsets for weights and biases
    uint32_t plm_offset_W1 = 0;
    uint32_t plm_offset_W2 = plm_offset_W1 + W1_size;
#ifdef do_bias
    uint32_t plm_offset_B1 = plm_offset_W2 + W2_size;
    uint32_t plm_offset_B2 = plm_offset_B1 + B1_size;
#endif

    // PLM access offset for input data
    // for sw-only version, added offset to take into account load batch
    uint32_t batch_offset = indata_offset + num_electrodes * tsamps_perbatch * batch;

    // useful for arithmetic
    uint32_t W1_singlewindow = layer1_dimension*input_dimension;
    uint32_t W2_singlewindow = output_dimension*layer1_dimension;

    // iter accumulation variables for batched backprop
/*
    TYPE dW2[W2_size];
    TYPE dW1[W1_size];
    TYPE dB2[B2_size];
    TYPE dB1[B1_size];
*/
    // TODO rewrite to not use arbitrarily sized arrasy
    const uint32_t const_W2_size = CONST_NUM_WINDOWS * CONST_WINDOW_SIZE * CONST_NEURONS_PERWIN;
    const uint32_t const_W1_size = const_W2_size;
    const uint32_t const_B2_size = CONST_NUM_WINDOWS * CONST_WINDOW_SIZE;
    const uint32_t const_B1_size = CONST_NUM_WINDOWS * CONST_NEURONS_PERWIN;
    
    TYPE dW2[const_W2_size];
    TYPE dW1[const_W1_size];
#ifdef do_bias
    TYPE dB2[const_B2_size];
    TYPE dB1[const_B1_size];
#endif

    // temporary variables to store some results
    // forward pass: activation of layer 1 and difference between out and in
/*
    TYPE act1[num_windows*layer1_dimension];
    TYPE diff[num_windows*output_dimension];
*/
    // TODO rewrite to not use arbitrarily sized arrays
    TYPE act1[const_B1_size];
    TYPE diff[const_B2_size];

    // backward pass: sample accum variable W2(x2-x0) used for backprop
/*
    TYPE W2xdiff[num_windows*layer1_dimension];
*/
    // TODO rewrite to not use arbitrarily sized arrays
    TYPE W2xdiff[const_B1_size];

    for (uint32_t iter = 0; iter < iters_perbatch; iter++) {
        
        // reset weight and bias delta accumulation variables
        // assumes W2_size = W1_size
        for (uint32_t i = 0; i < W2_size; i++) {
            dW1[i] = a_write(0.0);
            dW2[i] = a_write(0.0);
            
#ifdef do_bias
            if (i < B2_size) {
                dB2[i] = a_write(0.0);
            }
            if (i < B1_size) {
                dB1[i] = a_write(0.0);
            }
#endif
        }

        for (uint32_t samp = 0; samp < tsamps_perbatch; samp++) {

            // offset to access input data for this time samp
            samp_offset = batch_offset + samp*num_electrodes;

            // access input data for all windows from PLM
            // only place we need to worry about pingpong
            for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                // this is a PLM access - can only UNROLL if has multiple ports
                elecdata[elec] = a_write(a_read(in[samp_offset + elec]));

            }

            for (uint32_t window = 0; window < num_windows; window++) {
                // TODO UNROLL? - if so, need to fix the offsets

                if (flag[window]) {

                    // compute some offsets for loop indexing
                    window_offset_dW1 = window*W1_singlewindow;
                    window_offset_dW2 = window*W2_singlewindow;
                    window_offset_weights1 = plm_offset_W1 + window_offset_dW1;
                    window_offset_weights2 = plm_offset_W2 + window_offset_dW2;
                    window_offset_output = window*output_dimension;
                    window_offset_layer1 = window*layer1_dimension;
                    window_offset_input = window*input_dimension;
                    
#ifdef do_bias
                    window_offset_biases1 = plm_offset_B1 + window_offset_layer1;
                    window_offset_biases2 = plm_offset_B2 + window_offset_output;
#endif

                    // forward pass
                    // compute layer1 activations

                    // dummy variable for activation increment
                    TYPE temp_act1;
                    TYPE temp_incr;
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        // reset activation for this sample
                        act1[window_offset_layer1 + neuron] = a_write(0.0);

                        // mac
                        for (uint32_t in = 0; in < input_dimension; in++) {

                            // acquire existing act1
                            temp_act1 = a_read(act1[window_offset_layer1 + neuron]);
                            // compute (FP) increment
                            temp_incr = a_read(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + in]) *
                                a_read(elecdata[window_offset_input + in]);
                            // update act1
                            act1[window_offset_layer1 + neuron] =
                                a_write(temp_incr + temp_act1);

                        }
                     
                        // bias
#ifdef do_bias
                        // acquire existing act1
                        temp_act1 = a_read(act1[window_offset_layer1 + neuron]);
                        // compute (FP) increment
                        temp_incr = a_read(plm_out[window_offset_biases1 + neuron]);
                        // update act1
                        act1[window_offset_layer1 + neuron] =
                            a_write(temp_incr + temp_act1);
#endif
                    }

                    // compute output activations
                    TYPE temp_diff;
#ifdef do_bias
                    TYPE temp_dB2;
#endif
                    for (uint32_t out = 0; out < output_dimension; out++) {

                        // reset output difference for this sample
                        diff[window_offset_output + out] = a_write(0.0);

                        // mac
                        for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                            // acquire existing diff
                            temp_diff = a_read(diff[window_offset_output + out]);
                            // compute (FP) increment
                            temp_incr = a_read(plm_out[window_offset_weights2 +
                                    out*layer1_dimension + neuron]) *
                                a_read(act1[window_offset_layer1 + neuron]);
                            // update diff
                            diff[window_offset_output + out] =
                                a_write(temp_incr + temp_diff);

                        }
                        
                        // acquire existing diff
                        temp_diff = a_read(diff[window_offset_output + out]);

                        // subtract the ground truth difference
                        // we don't need the output, only the difference
                        temp_incr = -1 * a_read(elecdata[window_offset_input + out]);

                        // bias
#ifdef do_bias
                        temp_incr = temp_incr + a_read(plm_out[window_offset_biases2 + out]);
#endif

                        // update diff
                        diff[window_offset_output + out] =
                            a_write(temp_incr + temp_diff);

                        // beginning of backprop for this sample
                        // this part only requires a loop over output
                        // iter-accum dB2 - simple because we just add diff
#ifdef do_bias
                        temp_dB2 = a_read(dB2[window_offset_output + out]);
                        temp_incr = ((TYPE)2.0) * a_read(diff[window_offset_output + out]);
                        dB2[window_offset_output + out] = a_write(temp_dB2 + temp_incr);
#endif
                    }

                    TYPE temp_W2xdiff;
                    TYPE temp_dW2;
#ifdef do_bias
                    TYPE temp_dB1;
#endif
                    TYPE temp_dW1;
                    // backprop for this sample (with no weight update yet)
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        // reset W2xdiff sample accum variable
                        W2xdiff[window_offset_layer1 + neuron] = a_write(0.0);

                        // dual-purpose loop; both computations here looped over neurons and outputs
                        // they are unrelated
                        for (uint32_t out = 0; out < output_dimension; out++) {

                            // mac W2xdiff

                            // acquire existing W2xdiff
                            temp_W2xdiff = a_read(W2xdiff[window_offset_layer1 + neuron]);
                            // compute (FP) increment
                            temp_incr = a_read(plm_out[window_offset_weights2 +
                                    out*layer1_dimension + neuron]) *
                                a_read(diff[window_offset_output + out]);
                            // update W2xdiff
                            W2xdiff[window_offset_layer1 + neuron] =
                                a_write(temp_incr + temp_W2xdiff);

                            // iter-accum dW2

                            // acquire existing dW2
                            temp_dW2 = a_read(
                                dW2[window_offset_dW2 + out*layer1_dimension + neuron]);
                            // compute (FP) increment
                            temp_incr = ((TYPE)2.0) * a_read(diff[window_offset_output + out]) *
                                a_read(act1[window_offset_layer1 + neuron]);
                            // update dW2
                            dW2[window_offset_dW2 + out*layer1_dimension + neuron] = 
                                a_write(temp_incr + temp_dW2);
                        }

                        // these must be done after because they depend on W2xdiff

                        // iter-accum dB1
#ifdef do_bias
                        // acquire existing dB1
                        temp_dB1 = a_read(
                            dB1[window_offset_layer1 + neuron]);
                        // compute (FP) increment
                        temp_incr = ((TYPE)2.0) * a_read(W2xdiff[window_offset_layer1 + neuron]);
                        // update dB1
                        dB1[window_offset_layer1 + neuron] = 
                            a_write(temp_incr + temp_dB1);
#endif

                        // iter-accum dW1
                        for (uint32_t in = 0; in < input_dimension; in++) {

                            // acquire existing dW1
                            temp_dW1 = a_read(
                                dW1[window_offset_dW1 + neuron*input_dimension + in]);
                            // compute (FP) increment
                            temp_incr = ((TYPE)2.0) * a_read(W2xdiff[window_offset_layer1 + neuron]) *
                                        a_read(elecdata[window_offset_input + in]);
                            // update dW1
                            dW1[window_offset_dW1 + neuron*input_dimension + in] = 
                                a_write(temp_incr + temp_dW1);
                        }
                    }
                }
                // end of this window
            }
            // this sample is complete for this iter
        }

        // all samples have now been processed,
        // and we are ready to perform a weight update for this iter
        TYPE temp_plmval;
        TYPE temp_incr;
        for (uint32_t window = 0; window < num_windows; window++) {
            // TODO UNROLL?

            if (flag[window]) {

                // compute some offsets for loop indexing
                window_offset_dW1 = window*W1_singlewindow;
                window_offset_dW2 = window*W2_singlewindow;
                window_offset_weights1 = plm_offset_W1 + window_offset_dW1;
                window_offset_weights2 = plm_offset_W2 + window_offset_dW2;
                window_offset_output = window*output_dimension;
                window_offset_layer1 = window*layer1_dimension;
                window_offset_input = window*input_dimension;
#ifdef do_bias
                window_offset_biases1 = plm_offset_B1 + window_offset_layer1;
                window_offset_biases2 = plm_offset_B2 + window_offset_output;
#endif

                // these normalizations only useful for this window
                TYPE norm, bias_norm;
                norm = 0.0;
                bias_norm = 0.0;

                for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {
                    
                    // update B1
#ifdef do_bias
                    // acquire existing plmval
                    temp_plmval = a_read(
                        plm_out[window_offset_biases1 + neuron]);
                    // compute (FP) increment
                    temp_incr = a_read(dB1[window_offset_layer1 + neuron]) *
                        (learning_rate_scaled);

                    // update plmval
                    plm_out[window_offset_biases1 + neuron] = 
                        a_write(temp_plmval - temp_incr);
#endif

/*
                    // add to bias normalization
                    bias_norm += a_read(plm_out[window_offset_biases1 + neuron]) *
                        a_read(plm_out[window_offset_biases1 + neuron]);
*/

                    // update W1
                    for (uint32_t in = 0; in < input_dimension; in++) {

                        // acquire existing plmval
                        temp_plmval = a_read(
                            plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                        if ((window == 0) && (neuron == 0) && (in == 0)) {
                            cout << "before " << temp_plmval << "\n";
                        }
                        // compute (FP) increment

                        temp_incr = a_read(dW1[window_offset_dW1
                                + neuron*input_dimension + in]) * (learning_rate_scaled);

                        if ((window == 0) && (neuron == 0) && (in == 0)) {
                            cout << "increment " << -1.0*temp_incr << "\n";
                        }
                        // update plmval
                        plm_out[window_offset_weights1 + neuron*input_dimension + in] = 
                            a_write(temp_plmval - temp_incr);

                        // for testing
                        temp_plmval = a_read(
                            plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                        if ((window == 0) && (neuron == 0) && (in == 0)) {
                            cout << "after " << temp_plmval << "\n";
                        }

/*
                        // add to weight normalization
                        norm +=
                            a_read(plm_out[window_offset_weights1 +
                                neuron*input_dimension + in]) *
                            a_read(plm_out[window_offset_weights1 +
                                neuron*input_dimension + in]);
*/
                    }
                }

                // TODO normalization is temporarily disallowed,
                // until we figure out how to do sqrt and
                // whether division is ok
                // TODO revisit normalization code above to reflect changes to PLM access += -=
                /*               
                norm = sqrt(norm);
                bias_norm = sqrt(bias_norm);

                // perform normalization
                for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                    // bias normalization
                    plm_out[window_offset_biases1 + neuron] =
                        a_write(a_read(
                            plm_out[window_offset_biases1 + neuron]) / bias_norm);
                    
                    // weight normalization
                    for (uint32_t in = 0; in < input_dimension; in++) {

                        plm_out[window_offset_weights1 + neuron*input_dimension + in] =
                            a_write(a_read(
                                plm_out[window_offset_weights1 + neuron*input_dimension + in]) / norm);
                    }
                }

                norm = (TYPE)0.0;
                bias_norm = (TYPE)0.0;
                */

                for (uint32_t out = 0; out < output_dimension; out++) {
                    
                    // update B2

#ifdef do_bias
                    // acquire existing plmval
                    temp_plmval = a_read(
                        plm_out[window_offset_biases2 + out]);
                    // compute (FP) increment
                    temp_incr = a_read(dB2[window_offset_output + out]) *
                        (learning_rate);

                    // update plmval
                    plm_out[window_offset_biases2 + out] = 
                        a_write(temp_plmval - temp_incr);
#endif

/*
                    // add to bias normalization
                    bias_norm += a_read(plm_out[window_offset_biases2 + out]) *
                        a_read(plm_out[window_offset_biases2 + out]);
*/

                    // update W2
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        // acquire existing plmval
                        temp_plmval = a_read(
                            plm_out[window_offset_weights2 + out*layer1_dimension + neuron]);
                        if ((window == 0) && (neuron == 0) && (out == 0)) {
                            cout << "before " << temp_plmval << "\n";
                        }
                        // compute (FP) increment
                        temp_incr = a_read(dW2[window_offset_dW2
                                + out*layer1_dimension + neuron]) *
                            (learning_rate);
                        if ((window == 0) && (neuron == 0) && (out == 0)) {
                            cout << "increment " << -1.0*temp_incr << "\n";
                        }
                        // update plmval
                        plm_out[window_offset_weights2 + out*layer1_dimension + neuron] =
                            a_write(temp_plmval - temp_incr);

                        // for testing
                        temp_plmval = a_read(
                            plm_out[window_offset_weights2 + out*layer1_dimension + neuron]);
                        if ((window == 0) && (neuron == 0) && (out == 0)) {
                            cout << "after " << temp_plmval << "\n";
                        }

/*
                        // add to weight normalization
                        norm +=
                            a_read(plm_out[window_offset_weights2 +
                                out*layer1_dimension + neuron]) *
                            a_read(plm_out[window_offset_weights2 +
                                out*layer1_dimension + neuron]);
*/
                    }
                }
                
                // TODO normalization is temporarily disallowed,
                // until we figure out how to do sqrt and
                // whether division is ok
                /*
                norm = sqrt(norm);
                bias_norm = sqrt(bias_norm);

                // perform normalization
                for (uint32_t out = 0; out < output_dimension; out++) {

                    // bias normalization
                    plm_out[window_offset_biases2 + out] =
                        a_write(a_read(
                            plm_out[window_offset_biases2 + out]) / bias_norm);
                    
                    // weight normalization
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        plm_out[window_offset_weights2 + out*layer1_dimension + neuron] =
                            a_write(a_read(
                                plm_out[window_offset_weights2 + out*layer1_dimension + neuron]) / norm);
                    }
                }
                */
            }
            // this window is now complete
        }
        // this iter is now complete
    }
    // all iters complete
}
