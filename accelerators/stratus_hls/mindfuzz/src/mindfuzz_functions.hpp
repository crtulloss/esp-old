// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// Optional application-specific helper functions

// Caleb Rees Tulloss
// Bioelectronic Systems Lab
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
void mindfuzz::thresh_update_scalar(int32_t num_windows,
                                    int32_t window_size,
                                    TYPE rate_spike,
                                    TYPE rate_noise,
                                    TYPE spike_weight) {

    TYPE data;
    TYPE m_spike;
    TYPE m_noise;
    TYPE delta_spike;
    TYPE delta_noise;
    TYPE delta_spike_abs;
    TYPE delta_noise_abs;

    uint32_t total_offset;

    for (uint32_t window = 0; window < num_windows; window++) {
        
        total_offset = window * window_size;

        for (uint32_t elec = 0; elec < window_size; elec++) {

            // acquire sample for this electrode
            // note that in current version, this data will be max-min for a time window
            data = a_read(plm_maxmin[total_offset + elec]);

            // acquire relevant means
            m_spike = a_read(plm_mean_spike[total_offset + elec]);
            m_noise = a_read(plm_mean_noise[total_offset + elec]);

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
                plm_mean_spike[total_offset + elec] = a_write(m_spike);
            }

            else {
                // noise cluster
                // update the mean
                m_noise = m_noise + delta_noise * rate_noise;
                plm_mean_noise[total_offset + elec] = a_write(m_noise);
            }

            // update thresh
            plm_thresh[total_offset + elec] = a_write(spike_weight * (m_spike + m_noise));

            // done with this electrode
        }
        // done with this window
    }
}

// updates threshold between spike and noise for a given time window
// vector version
void mindfuzz::thresh_update_vector(int32_t num_windows,
                                    int32_t window_size,
                                    TYPE rate_spike,
                                    TYPE rate_noise,
                                    TYPE spike_weight) {

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

    uint32_t total_offset;

    for (uint32_t window = 0; window < num_windows; window++) {
        
        total_offset = window * window_size;
        
        // reset norm for this window
        norm_spike = (TYPE)0.0;
        norm_noise = (TYPE)0.0;

        for (uint32_t elec = 0; elec < window_size; elec++) {

            // acquire sample for this electrode
            // note that in current version, this data will be max-min for a time window
            data = a_read(plm_maxmin[total_offset + elec]);

            // acquire relevant means
            m_spike = a_read(plm_mean_spike[total_offset + elec]);
            m_noise = a_read(plm_mean_noise[total_offset + elec]);

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
            data = a_read(plm_maxmin[total_offset + elec]);

            // acquire relevant means
            m_spike = a_read(plm_mean_spike[total_offset + elec]);
            m_noise = a_read(plm_mean_noise[total_offset + elec]);

            if (spike) {
                // spike cluster
                // update the mean
                delta_spike = data - m_spike;
                m_spike = m_spike + delta_spike * rate_spike;
                plm_mean_spike[total_offset + elec] = a_write(m_spike);
            }
            else {
                // noise cluster
                // update the mean
                delta_noise = data - m_noise;
                m_noise = m_noise + delta_noise * rate_noise;
                plm_mean_noise[total_offset + elec] = a_write(m_noise);
            }

            // update thresh
            plm_thresh[total_offset + elec] = a_write(spike_weight * (m_spike + m_noise));

            // done with this electrode
        }

        // done with this window
    }
}

// relavancy detection used to choose input data
void mindfuzz::relevant(int32_t total_tsamps,
                        int32_t num_windows,
                        int32_t window_size,
                        bool flag[],
                        bool ping) {

    TYPE data;
    TYPE maxmin;
    TYPE thresh;

    uint32_t num_electrodes = num_windows*window_size;

    // TODO sized using fixed magic numbers based on max accel config
    // need to define arrays using the sc_int datatype because they are mapped to PLMs
    sc_dt::sc_int<DATA_WIDTH> max[PLM_ELEC_WORD];
    sc_dt::sc_int<DATA_WIDTH> min[PLM_ELEC_WORD];

    uint32_t samp_offset;
    uint32_t window_offset;
    uint32_t total_offset;

    // first, process all time samples to find max and min for each elec
    for (uint32_t samp = 0; samp < total_tsamps; samp++) {

        samp_offset = samp * num_electrodes;
        
        for (uint32_t window = 0; window < num_windows; window++) {

            window_offset = window * window_size;
            total_offset = samp_offset + window_offset;

            for (uint32_t elec = 0; elec < window_size; elec++) {

                // on first sample for each elec, reset the max and min
                if (samp == 0) {
                    max[window_offset + elec] = a_write(0.0);
                    min[window_offset + elec] = a_write(0.0);
                }

                if (ping) {
                    data = a_read(plm_in_ping[total_offset + elec]);
                }
                else {
                    data = a_read(plm_in_pong[total_offset + elec]);
                }

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
          
            // calculate max-min
            maxmin = a_read(max[window_offset + elec]) - a_read(min[window_offset + elec]);

            // update in plm
            plm_maxmin[window_offset + elec] = a_write(maxmin);

            // acquire thresh for this electrode
            thresh = a_read(plm_thresh[window_offset + elec]);

            if (maxmin > thresh) {
                // flag the window
                flag[window] = true;
            }
        }
        // done with this window
    }

    // done
}

// backprop function with multiple hidden components in series
void mindfuzz::backprop(TYPE learning_rate,
                        int32_t tsamps_perbatch,
                        int32_t num_windows,
                        int32_t iters_perbatch,
                        int32_t input_dimension,
                        int32_t layer1_dimension,
                        int32_t W_size,
                        int32_t batch,
                        bool flag[],
                        bool ping) {

    // single-tsamp data for all electrodes - size e.g. 4 * 32 = 256
    uint32_t num_electrodes = num_windows*input_dimension;
    
    // TODO FLATTEN THIS?
    // if so, need to add a_read to where input is read
    sc_dt::sc_int<DATA_WIDTH> elecdata[PLM_ELEC_WORD];

    // some offsets useful for indexing
    uint32_t samp_offset;
    uint32_t window_offset_weights1;
    uint32_t window_offset_layer1;
    uint32_t window_offset_input;

    // PLM access offset for input data
    // for sw-only version, added offset to take into account load batch
    uint32_t batch_offset = num_electrodes * tsamps_perbatch * batch;

    // useful for arithmetic
    uint32_t W1_singlewindow = layer1_dimension*input_dimension;

    // iter accumulation variables for batched backprop
    // TODO rewrite to not use arbitrarily sized arrasy
    const uint32_t const_W1_size = CONST_NUM_WINDOWS * CONST_WINDOW_SIZE * CONST_NEURONS_PERWIN;
    const uint32_t const_diff_size = CONST_NUM_WINDOWS * CONST_WINDOW_SIZE;
    const uint32_t const_act1_size = CONST_NUM_WINDOWS * CONST_NEURONS_PERWIN;
    
    sc_dt::sc_int<DATA_WIDTH> dW1[const_W1_size];

    // temporary variables to store some results
    // forward pass: activation of layer 1 and difference between out and in
    // TODO rewrite to not use arbitrarily sized arrays
    sc_dt::sc_int<DATA_WIDTH> act1[const_act1_size];
    sc_dt::sc_int<DATA_WIDTH> out[const_diff_size];
    sc_dt::sc_int<DATA_WIDTH> diff[const_diff_size];

    for (uint32_t iter = 0; iter < iters_perbatch; iter++) {
        
        // reset weight delta accumulation variables
        for (uint32_t i = 0; i < W_size; i++) {
            dW1[i] = a_write(0.0);
        }

        for (uint32_t samp = 0; samp < tsamps_perbatch; samp++) {

            // offset to access input data for this time samp
            samp_offset = batch_offset + samp*num_electrodes;

            // access input data for all windows from PLM
            // only place we need to worry about pingpong
            if (ping) {
                for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                    // this is a PLM access - can only UNROLL if has multiple ports
                    elecdata[elec] = plm_in_ping[samp_offset + elec];
                }
            }
            else {
                for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                    // this is a PLM access - can only UNROLL if has multiple ports
                    elecdata[elec] = plm_in_pong[samp_offset + elec];
                }
            }

            for (uint32_t window = 0; window < num_windows; window++) {
                // TODO UNROLL? - if so, need to fix the offsets

                // do backprop only on noise data
                if (!flag[window]) {

                    // compute some offsets for loop indexing
                    window_offset_weights1 = window*W1_singlewindow;
                    window_offset_layer1 = window*layer1_dimension;
                    window_offset_input = window*input_dimension;
                    

                    // forward pass

                    // dummy variables for layer 1 activation increment
                    TYPE temp_act1;
                    TYPE temp_incr;
                    // dummy variable for output activation
                    TYPE temp_out;
                    // dummy variable for weight delta
                    TYPE temp_dW1

                    // processing for each "neuron" is done in series
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        // compute layer1 activation for this window
                        // reset activation accumulation variable for this sample
                        temp_act1 = (TYPE)0.0;

                        // mac
                        for (uint32_t in = 0; in < input_dimension; in++) {

                            // compute (FP) increment
                            temp_incr = a_read(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + in]) *
                                a_read(elecdata[window_offset_input + in]);
                            // add to accum variable
                            temp_act1 = temp_act1 + temp_incr;
                        }
                     
                        // update act1
                        act1[window_offset_layer1 + neuron] = a_write(temp_act1);

                        // compute outputs and differences (out - in)
                        // note no mac here bc the outputs are computed in series
                        // so the computation for each output is a scalar mult
                        for (uint32_t out = 0; out < input_dimension; out++) {
                        
                            // compute output
                            temp_out = 
                                a_read(plm_out[window_offset_weights1 + neuron*input_dimension + out]) *
                                a_read(act1[window_offset_layer1 + neuron]);
                            out[window_offset_input + out] = a_write(temp_out);

                            // subtract the ground truth difference
                            diff[window_offset_input + out] = a_write(
                                temp_out - a_read(elecdata[window_offset_input + out]));
                       
                            // begin backprop: accumulate weight delta
                            
                            // acquire existing dW1
                            temp_dW1 = a_read(
                                dW1[window_offset_weights1 + neuron*input_dimension + out]);
                            // compute increment
                            temp_incr = ((type)2.0) * a_read(diff[window_offset_input + out]) *
                                a_read(act1[window_offset_layer1 + neuron]);
                            // update dW1
                            dW1[window_offset_weights1 + neuron*input_dimension + out] = 
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

            // update weights only for noise data
            if (!flag[window]) {

                // compute some offsets for loop indexing
                window_offset_weights1 = window*W1_singlewindow;
                window_offset_layer1 = window*layer1_dimension;
                window_offset_input = window*input_dimension;

                for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {
                    
                    // update W1
                    for (uint32_t in = 0; in < input_dimension; in++) {

                        // acquire existing plmval
                        temp_plmval = a_read(
                            plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                        // compute (FP) increment
                        temp_incr = a_read(dW1[window_offset_weights1
                                + neuron*input_dimension + in]) * (learning_rate);
                        // update plmval
                        plm_out[window_offset_weights1 + neuron*input_dimension + in] = 
                            a_write(temp_plmval - temp_incr);

                    }
                }
            }
            // this window is now complete
        }
        // this iter is now complete
    }
    // all iters complete
}

// backprop function used in computational kernel
// legacy version with multiple components in parallel
/*
void mindfuzz::backprop(TYPE learning_rate,
                        int32_t tsamps_perbatch,
                        int32_t num_windows,
                        int32_t iters_perbatch,
                        int32_t input_dimension,
                        int32_t layer1_dimension,
                        int32_t W1_size,
                        int32_t B1_size,
                        int32_t B2_size,
                        int32_t batch,
                        bool flag[],
                        bool ping) {

    // single-tsamp data for all electrodes - size e.g. 4 * 32 = 256
    uint32_t num_electrodes = num_windows*input_dimension;
    
    // TODO FLATTEN THIS?
    // if so, need to add a_read to where input is read
    sc_dt::sc_int<DATA_WIDTH> elecdata[PLM_ELEC_WORD];

    // some offsets useful for indexing
    uint32_t samp_offset;
    uint32_t window_offset_dW1;
    uint32_t window_offset_weights1;
    uint32_t window_offset_layer1;
    uint32_t window_offset_input;
#ifdef do_bias
    uint32_t window_offset_biases2;
    uint32_t window_offset_biases1;
#endif

    // PLM access offsets for weights and biases
    uint32_t plm_offset_W1 = 0;
#ifdef do_bias
    uint32_t plm_offset_B1 = plm_offset_W1 + W1_size;
    uint32_t plm_offset_B2 = plm_offset_B1 + B1_size;
#endif

    // PLM access offset for input data
    // for sw-only version, added offset to take into account load batch
    uint32_t batch_offset = num_electrodes * tsamps_perbatch * batch;

    // useful for arithmetic
    uint32_t W1_singlewindow = layer1_dimension*input_dimension;

    // iter accumulation variables for batched backprop
    // TODO rewrite to not use arbitrarily sized arrasy
    const uint32_t const_W1_size = CONST_NUM_WINDOWS * CONST_WINDOW_SIZE * CONST_NEURONS_PERWIN;
    const uint32_t const_B2_size = CONST_NUM_WINDOWS * CONST_WINDOW_SIZE;
    const uint32_t const_B1_size = CONST_NUM_WINDOWS * CONST_NEURONS_PERWIN;
    
    sc_dt::sc_int<DATA_WIDTH> dW1[const_W1_size];
#ifdef do_bias
    sc_dt::sc_int<DATA_WIDTH> dB2[const_B2_size];
    sc_dt::sc_int<DATA_WIDTH> dB1[const_B1_size];
#endif

    // temporary variables to store some results
    // forward pass: activation of layer 1 and difference between out and in
    // TODO rewrite to not use arbitrarily sized arrays
    sc_dt::sc_int<DATA_WIDTH> act1[const_B1_size];
    sc_dt::sc_int<DATA_WIDTH> diff[const_B2_size];

#ifdef do_bias
    // backward pass: sample accum variable W2(x2-x0) used for backprop
    // would be used by dW1 and dB1
    // TODO rewrite to not use arbitrarily sized arrays
    sc_dt::sc_int<DATA_WIDTH> W2xdiff[const_B1_size];
#endif

    for (uint32_t iter = 0; iter < iters_perbatch; iter++) {
        
        // reset weight and bias delta accumulation variables
        for (uint32_t i = 0; i < W2_size; i++) {
            dW1[i] = a_write(0.0);
            
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
            if (ping) {
                for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                    // this is a PLM access - can only UNROLL if has multiple ports
                    elecdata[elec] = plm_in_ping[samp_offset + elec];
                }
            }
            else {
                for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                    // this is a PLM access - can only UNROLL if has multiple ports
                    elecdata[elec] = plm_in_pong[samp_offset + elec];
                }
            }

            for (uint32_t window = 0; window < num_windows; window++) {
                // TODO UNROLL? - if so, need to fix the offsets

                // do backprop only on noise data
                if (!flag[window]) {

                    // compute some offsets for loop indexing
                    window_offset_dW1 = window*W1_singlewindow;
                    window_offset_weights1 = plm_offset_W1 + window_offset_dW1;
                    window_offset_layer1 = window*layer1_dimension;
                    window_offset_input = window*input_dimension;
                    
#ifdef do_bias
                    window_offset_biases1 = plm_offset_B1 + window_offset_layer1;
                    window_offset_biases2 = plm_offset_B2 + window_offset_input;
#endif

                    // forward pass
                    // compute layer1 activations

                    // dummy variable for activation increment
                    TYPE temp_act1;
                    TYPE temp_incr;
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        // reset activation accumulation variable for this sample
                        temp_act1 = (TYPE)0.0;

                        // mac
                        for (uint32_t in = 0; in < input_dimension; in++) {

                            // compute (FP) increment
                            temp_incr = a_read(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + in]) *
                                a_read(elecdata[window_offset_input + in]);
                            // add to accum variable
                            temp_act1 = temp_act1 + temp_incr;
                        }
                     
                        // bias
#ifdef do_bias
                        // compute (FP) increment
                        temp_incr = a_read(plm_out[window_offset_biases1 + neuron]);
                        // add to accum variable
                        temp_act1 = temp_act1 + temp_incr;
#endif
                        // update act1
                        act1[window_offset_layer1 + neuron] = a_write(temp_act1);
                    }

                    // compute output activations
                    TYPE temp_diff;
#ifdef do_bias
                    TYPE temp_dB2;
#endif
                    for (uint32_t out = 0; out < input_dimension; out++) {

                        // reset output difference accumulation variable for this sample
                        temp_diff = (TYPE)0.0;

                        // mac
                        for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                            // compute (FP) increment - note that we are using the same weights as layer 1
                            temp_incr = a_read(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + out]) *
                                a_read(act1[window_offset_layer1 + neuron]);
                            // add to accum variable
                            temp_diff = temp_diff + temp_incr;
                        }
                        
                        // subtract the ground truth difference
                        // we don't need the output, only the difference
                        temp_incr = ((TYPE)-1.0) * a_read(elecdata[window_offset_input + out]);
                        temp_diff = temp_diff + temp_incr;

                        // bias
#ifdef do_bias
                        temp_incr = a_read(plm_out[window_offset_biases2 + out]);
                        temp_diff = temp_diff + temp_incr;
#endif
                        // update diff
                        diff[window_offset_input + out] = a_write(temp_diff);

                        // beginning of backprop for this sample
                        // this part only requires a loop over output
                        // iter-accum dB2 - simple because we just add diff
#ifdef do_bias
                        temp_dB2 = a_read(dB2[window_offset_input + out]);
                        temp_incr = ((TYPE)2.0) * a_read(diff[window_offset_input + out]);
                        dB2[window_offset_input + out] = a_write(temp_dB2 + temp_incr);
#endif
                    }

#ifdef do_bias
                    TYPE temp_W2xdiff;
                    TYPE temp_dB1;
#endif
                    TYPE temp_dW1;
                    // backprop for this sample (with no weight update yet)
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

#ifdef do_bias
                        // reset W2xdiff sample accum variable
                        W2xdiff[window_offset_layer1 + neuron] = a_write(0.0);
#endif

                        // dual-purpose loop; both computations here looped over neurons and outputs
                        // they are unrelated
                        for (uint32_t out = 0; out < input_dimension; out++) {

#ifdef do_bias
                            // mac W2xdiff

                            // acquire existing W2xdiff
                            temp_W2xdiff = a_read(W2xdiff[window_offset_layer1 + neuron]);
                            // compute (FP) increment
                            temp_incr = a_read(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + out]) *
                                a_read(diff[window_offset_input + out]);
                            // update W2xdiff
                            W2xdiff[window_offset_layer1 + neuron] =
                                a_write(temp_incr + temp_W2xdiff);
#endif

                            // iter-accum dW1

                            // acquire existing dW1
                            temp_dW1 = a_read(
                                dW1[window_offset_dW1 + neuron*input_dimension + out]);
                            // compute (FP) increment
                            temp_incr = ((TYPE)2.0) * a_read(diff[window_offset_input + out]) *
                                a_read(act1[window_offset_layer1 + neuron]);
                            // update dW1
                            dW1[window_offset_dW1 + neuron*input_dimension + out] = 
                                a_write(temp_incr + temp_dW1);
                        }

#ifdef do_bias
                        // these must be done after because they depend on W2xdiff

                        // iter-accum dB1
                        // acquire existing dB1
                        temp_dB1 = a_read(
                            dB1[window_offset_layer1 + neuron]);
                        // compute (FP) increment
                        temp_incr = ((TYPE)2.0) * a_read(W2xdiff[window_offset_layer1 + neuron]);
                        // update dB1
                        dB1[window_offset_layer1 + neuron] = 
                            a_write(temp_incr + temp_dB1);
#endif
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

            // update weights only for noise data
            if (!flag[window]) {

                // compute some offsets for loop indexing
                window_offset_dW1 = window*W1_singlewindow;
                window_offset_weights1 = plm_offset_W1 + window_offset_dW1;
                window_offset_layer1 = window*layer1_dimension;
                window_offset_input = window*input_dimension;
#ifdef do_bias
                window_offset_biases1 = plm_offset_B1 + window_offset_layer1;
                window_offset_biases2 = plm_offset_B2 + window_offset_input;
#endif

                for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {
                    
                    // update B1
#ifdef do_bias
                    // acquire existing plmval
                    temp_plmval = a_read(
                        plm_out[window_offset_biases1 + neuron]);
                    // compute (FP) increment
                    temp_incr = a_read(dB1[window_offset_layer1 + neuron]) *
                        (learning_rate);

                    // update plmval
                    plm_out[window_offset_biases1 + neuron] = 
                        a_write(temp_plmval - temp_incr);
#endif

                    // update W1
                    for (uint32_t in = 0; in < input_dimension; in++) {

                        // acquire existing plmval
                        temp_plmval = a_read(
                            plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                        // compute (FP) increment
                        temp_incr = a_read(dW1[window_offset_dW1
                                + neuron*input_dimension + in]) * (learning_rate);
                        // update plmval
                        plm_out[window_offset_weights1 + neuron*input_dimension + in] = 
                            a_write(temp_plmval - temp_incr);

                    }
                }

#ifdef do_bias
                // update B2
                for (uint32_t out = 0; out < input_dimension; out++) {
                    
                    // acquire existing plmval
                    temp_plmval = a_read(
                        plm_out[window_offset_biases2 + out]);
                    // compute (FP) increment
                    temp_incr = a_read(dB2[window_offset_input + out]) *
                        (learning_rate);

                    // update plmval
                    plm_out[window_offset_biases2 + out] = 
                        a_write(temp_plmval - temp_incr);
                }
#endif
            }
            // this window is now complete
        }
        // this iter is now complete
    }
    // all iters complete
}
*/
