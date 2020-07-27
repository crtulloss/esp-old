// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "mindfuzz.hpp"

// Optional application-specific helper functions

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

// relavancy detection used to choose input data
void mindfuzz::relevant(int32_t total_tsamps,
                        int32_t num_windows,
                        int32_t window_size,
                        bool flag[],
                        bool ping,
                        TYPE thresh) {

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
            total_offset = samp_offset + window_offset;

            for (uint32_t elec = 0; elec < window_size; elec++) {

                // on first sample for each elec, reset the max and min
                if (samp == 0) {
                    max[window_offset + elec] = fp2int<TYPE, WORD_SIZE>(0.0);
                    min[window_offset + elec] = fp2int<TYPE, WORD_SIZE>(0.0);
                }

                // acquire data
                if (ping) {
                    data = int2fp<TYPE, WORD_SIZE>(plm_in_ping[total_offset + elec]);
                }
                else {
                    data = int2fp<TYPE, WORD_SIZE>(plm_in_pong[total_offset + elec]);
                }

                // compare data for this sample with existing max and min
                if (data > int2fp<TYPE, WORD_SIZE>(max[window_offset + elec])) {
                    max[window_offset + elec] = fp2int<TYPE, WORD_SIZE>(data);
                }
                else if (data < int2fp<TYPE, WORD_SIZE>(min[window_offset + elec])) {
                    min[window_offset + elec] = fp2int<TYPE, WORD_SIZE>(data);
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
            if ((int2fp<TYPE, WORD_SIZE>(max[window_offset + elec]) - int2fp<TYPE, WORD_SIZE>(min[window_offset + elec])) > (TYPE)0.9) {
                // flag the window
                flag[window] = true;
                // don't need to check other electrodes in this window
                break;
            }
        }
        // done with this window
    }

    // done
}

// backprop function used in computational kernel
void mindfuzz::backprop(bool do_relu,
                        TYPE learning_rate,
                        int32_t tsamps_perbatch,
                        int32_t num_windows,
                        int32_t epochs_perbatch,
                        int32_t input_dimension,
                        int32_t layer1_dimension,
                        int32_t output_dimension,
                        int32_t W1_size,
                        int32_t W2_size,
                        int32_t B1_size,
                        int32_t B2_size,
                        int32_t batch,
                        bool flag[],
                        bool ping) {

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
    uint32_t window_offset_biases2;
    uint32_t window_offset_biases1;

    // PLM access offsets for weights and biases
    uint32_t plm_offset_W1 = 0;
    uint32_t plm_offset_W2 = plm_offset_W1 + W1_size;
    uint32_t plm_offset_B1 = plm_offset_W2 + W2_size;
    uint32_t plm_offset_B2 = plm_offset_B1 + B1_size;

    // PLM access offset for input data
    uint32_t batch_offset = num_electrodes * tsamps_perbatch * batch;

    // useful for arithmetic
    uint32_t W1_singlewindow = layer1_dimension*input_dimension;
    uint32_t W2_singlewindow = output_dimension*layer1_dimension;

    // epoch accumulation variables for batched backprop
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
    TYPE dB2[const_B2_size];
    TYPE dB1[const_B1_size];

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

    for (uint32_t epoch = 0; epoch < epochs_perbatch; epoch++) {
        
        // reset weight and bias delta accumulation variables
        // assumes W2_size = W1_size
        for (uint32_t i = 0; i < W2_size; i++) {
            dW1[i] = fp2int<TYPE, WORD_SIZE>(0.0);
            dW2[i] = fp2int<TYPE, WORD_SIZE>(0.0);
            if (i < B2_size) {
                dB2[i] = fp2int<TYPE, WORD_SIZE>(0.0);
            }
            if (i < B1_size) {
                dB1[i] = fp2int<TYPE, WORD_SIZE>(0.0);
            }
        }

        for (uint32_t samp = 0; samp < tsamps_perbatch; samp++) {

            // offset to access input data for this time samp
            samp_offset = batch_offset + samp*num_electrodes;

            // access input data for all windows from PLM
            // only place we need to worry about pingpong
            if (ping) {
                for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                    // this is a PLM access - can only UNROLL if has multiple ports
                    elecdata[elec] = fp2int<TYPE, WORD_SIZE>(int2fp<TYPE, WORD_SIZE>(plm_in_ping[samp_offset + elec]));
/*
                    float temp_data = int2fp<TYPE, WORD_SIZE>(plm_in_ping[samp_offset + elec]);
                    ESP_REPORT_INFO("data, accessed properly, is %.8f", temp_data);
                    plm_in_ping[samp_offset + elec] = fp2int<TYPE, WORD_SIZE>(temp_data);
                    temp_data = int2fp<TYPE, WORD_SIZE>(plm_in_ping[samp_offset + elec]);
                    ESP_REPORT_INFO("data, after rewriting y, is %.8f", temp_data);
*/

                }
            }
            else {
                for (uint32_t elec = 0; elec < num_electrodes; elec++) {
                    // this is a PLM access - can only UNROLL if has multiple ports
                    elecdata[elec] = fp2int<TYPE, WORD_SIZE>(int2fp<TYPE, WORD_SIZE>(plm_in_pong[samp_offset + elec]));
                }
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
                    window_offset_biases1 = plm_offset_B1 + window_offset_layer1;
                    window_offset_biases2 = plm_offset_B2 + window_offset_output;

                    // forward pass
                    // compute layer1 activations

                    // dummy variable for activation increment
                    TYPE temp_act1;
                    TYPE temp_incr;
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

/*
                        ESP_REPORT_INFO("begin computation of this act1");
*/

                        // reset activation for this sample
                        act1[window_offset_layer1 + neuron] = fp2int<TYPE, WORD_SIZE>(0.0);

/*
                        float temp_data = int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                        ESP_REPORT_INFO("act1, initial is %.8f", temp_data);
*/

                        // mac
                        for (uint32_t in = 0; in < input_dimension; in++) {

/*
                            temp_data = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                            ESP_REPORT_INFO("W1 is %.8f", temp_data);
                            temp_data = int2fp<TYPE, WORD_SIZE>(elecdata[window_offset_input + in]);
                            ESP_REPORT_INFO("in is %.8f", temp_data);
                            temp_data = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + in]) *
                                int2fp<TYPE, WORD_SIZE>(elecdata[window_offset_input + in]);
                            ESP_REPORT_INFO("product is %.8f", temp_data);

                            float temp_act1 = int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
*/

                            // acquire existing act1
                            temp_act1 = int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                            // compute (FP) increment
                            temp_incr = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights1 +
                                    neuron*input_dimension + in]) *
                                int2fp<TYPE, WORD_SIZE>(elecdata[window_offset_input + in]);
                            // update act1
                            act1[window_offset_layer1 + neuron] =
                                fp2int<TYPE, WORD_SIZE>(temp_incr + temp_act1);

/*
                            temp_data = int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                            ESP_REPORT_INFO("new act is %.8f", temp_data);
*/

                        }
                     
                        // bias
                        // acquire existing act1
                        temp_act1 = int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                        // compute (FP) increment
                        temp_incr = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_biases1 + neuron]);
                        // update act1
                        act1[window_offset_layer1 + neuron] =
                            fp2int<TYPE, WORD_SIZE>(temp_incr + temp_act1);
/*
                        temp_data = int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                        ESP_REPORT_INFO("act1 after bias addition is %.8f", temp_data);
*/

                    }

                    // compute output activations
                    TYPE temp_diff;
                    TYPE temp_dB2;
                    for (uint32_t out = 0; out < output_dimension; out++) {

                        // reset output difference for this sample
                        diff[window_offset_output + out] = fp2int<TYPE, WORD_SIZE>(0.0);

                        // mac
                        for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {


                            // acquire existing diff
                            temp_diff = int2fp<TYPE, WORD_SIZE>(diff[window_offset_output + out]);
                            // compute (FP) increment
                            temp_incr = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights2 +
                                    out*layer1_dimension + neuron]) *
                                int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                            // update diff
                            diff[window_offset_output + out] =
                                fp2int<TYPE, WORD_SIZE>(temp_incr + temp_diff);

                        }

                        // bias
                        // acquire existing diff
                        temp_diff = int2fp<TYPE, WORD_SIZE>(diff[window_offset_output + out]);
                        // compute (FP) increment
                        temp_incr = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_biases2 + out]);
                        
                        // subtract the ground truth difference
                        // we don't need the output, only the difference
                        temp_incr = temp_incr -
                            int2fp<TYPE, WORD_SIZE>(elecdata[window_offset_input + out]);

                        // update diff
                        diff[window_offset_output + out] =
                            fp2int<TYPE, WORD_SIZE>(temp_incr + temp_diff);

/*
                        float temp_data = int2fp<TYPE, WORD_SIZE>(diff[window_offset_output + out]);
                        ESP_REPORT_INFO("diff, accessed properly, is %.8f", temp_data);
*/


                        // beginning of backprop for this sample
                        // this part only requires a loop over output
                        // epoch-accum dB2 - simple because we just add diff
                        temp_dB2 = int2fp<TYPE, WORD_SIZE>(dB2[window_offset_output + out]);
                        temp_incr = int2fp<TYPE, WORD_SIZE>(diff[window_offset_output + out]);
                        dB2[window_offset_output + out] = fp2int<TYPE, WORD_SIZE>(temp_dB2 + temp_incr);

                    }

                    TYPE temp_W2xdiff;
                    TYPE temp_dW2;
                    TYPE temp_dB1;
                    TYPE temp_dW1;
                    // backprop for this sample (with no weight update yet)
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        // reset W2xdiff sample accum variable
                        W2xdiff[window_offset_layer1 + neuron] = fp2int<TYPE, WORD_SIZE>(0.0);

                        // dual-purpose loop; both computations here looped over neurons and outputs
                        // they are unrelated
                        for (uint32_t out = 0; out < output_dimension; out++) {

                            // mac W2xdiff

                            // acquire existing W2xdiff
                            temp_W2xdiff = int2fp<TYPE, WORD_SIZE>(
                                W2xdiff[window_offset_layer1 + neuron]);
                            // compute (FP) increment
                            temp_incr = int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights2 +
                                    out*layer1_dimension + neuron]) *
                                int2fp<TYPE, WORD_SIZE>(diff[window_offset_output + out]);
                            // update W2xdiff
                            W2xdiff[window_offset_layer1 + neuron] =
                                fp2int<TYPE, WORD_SIZE>(temp_incr + temp_W2xdiff);

                            // epoch-accum dw2

                            // acquire existing dW2
                            temp_dW2 = int2fp<TYPE, WORD_SIZE>(
                                dW2[window_offset_dW2 + out*layer1_dimension + neuron]);
                            // compute (FP) increment
                            temp_incr = int2fp<TYPE, WORD_SIZE>(diff[window_offset_output + out]) *
                                int2fp<TYPE, WORD_SIZE>(act1[window_offset_layer1 + neuron]);
                            // update dW2
                            dW2[window_offset_dW2 + out*layer1_dimension + neuron] = 
                                fp2int<TYPE, WORD_SIZE>(temp_incr + temp_dW2);
                        }

                        // these must be done after because they depend on W2xdiff

                        // epoch-accum dB1

                        // acquire existing dB1
                        temp_dB1 = int2fp<TYPE, WORD_SIZE>(
                            dB1[window_offset_layer1 + neuron]);
                        // compute (FP) increment
                        temp_incr = int2fp<TYPE, WORD_SIZE>(W2xdiff[window_offset_layer1 + neuron]);
                        // update dB1
                        dB1[window_offset_layer1 + neuron] = 
                            fp2int<TYPE, WORD_SIZE>(temp_incr + temp_dB1);

                        // epoch-accum dW1
                        for (uint32_t in = 0; in < input_dimension; in++) {

                            // acquire existing dW1
                            temp_dW1 = int2fp<TYPE, WORD_SIZE>(
                                dW1[window_offset_dW1 + neuron*input_dimension + in]);
                            // compute (FP) increment
                            temp_incr = int2fp<TYPE, WORD_SIZE>(W2xdiff[window_offset_layer1 + neuron]) *
                                        int2fp<TYPE, WORD_SIZE>(elecdata[window_offset_input + in]);
                            // update dW1
                            dW1[window_offset_dW1 + neuron*input_dimension + in] = 
                                fp2int<TYPE, WORD_SIZE>(temp_incr + temp_dW1);
                        }
                    }
                }
                // end of this window
            }
            // this sample is complete for this epoch
        }

        // all samples have now been processed,
        // and we are ready to perform a weight update for this epoch
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
                window_offset_biases1 = plm_offset_B1 + window_offset_layer1;
                window_offset_biases2 = plm_offset_B2 + window_offset_output;

                // these normalizations only useful for this window
                TYPE norm, bias_norm;
                norm = 0.0;
                bias_norm = 0.0;

                for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {
                    
/*
                    TYPE prev_value = fp2int<TYPE, WORD_SIZE>(plm_out[window_offset_biases1 + neuron]);
*/

                    // update B1

                    // acquire existing plmval
                    temp_plmval = int2fp<TYPE, WORD_SIZE>(
                        plm_out[window_offset_biases1 + neuron]);
                    // compute (FP) increment
                    temp_incr = int2fp<TYPE, WORD_SIZE>(dB1[window_offset_layer1 + neuron]) *
                        ((TYPE)0.01);
/*
                    while ((temp_incr > ((TYPE)1.0)) || (temp_incr < ((TYPE)-1.0))) {
                        temp_incr = temp_incr * ((TYPE)0.1);
                    }
                    temp_incr = temp_incr * ((TYPE)0.05);
*/
                    // update plmval
                    plm_out[window_offset_biases1 + neuron] = 
                        fp2int<TYPE, WORD_SIZE>(temp_plmval - temp_incr);

/*
                    TYPE next_value = fp2int<TYPE, WORD_SIZE>(plm_out[window_offset_biases1 + neuron]);

                    if (int2fp<TYPE, WORD_SIZE>(dB1[window_offset_layer1 + neuron]) != (TYPE)0.0) {
                        //ESP_REPORT_INFO("delta nonzero");
                        if ((int2fp<TYPE, WORD_SIZE>(dB1[window_offset_layer1 + neuron]) * ((TYPE)0.01)) == 0.0) {
                            ESP_REPORT_INFO("delta nonzero, scaled delta zero!");
                        }
                    }
                    if (prev_value == next_value) {
                        ESP_REPORT_INFO("no update occured");
                    }
*/

/*
                    float temp_delta = (float) int2fp<TYPE, WORD_SIZE>(
                                           dB1[window_offset_layer1 + neuron]);
                    ESP_REPORT_INFO("delta, accessed properly, is %.8f", temp_delta);
                    temp_delta = (float) (int2fp<TYPE, WORD_SIZE>(
                                           dB1[window_offset_layer1 + neuron]) * (TYPE)0.01);                   
                    ESP_REPORT_INFO("scaled delta, accessed properly, is %.8f", temp_delta);
                    temp_delta = (float) (dB1[window_offset_layer1 + neuron]);
                    ESP_REPORT_INFO("delta, access wrong, is %.8f", temp_delta);
                    temp_delta = (float) (dB1[window_offset_layer1 + neuron] * (TYPE)0.01);
                    ESP_REPORT_INFO("scaled delta, access wrong, is %.8f", temp_delta);
*/

/*
                    // add to bias normalization
                    bias_norm += int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_biases1 + neuron]) *
                        int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_biases1 + neuron]);
*/

                    // update W1
                    for (uint32_t in = 0; in < input_dimension; in++) {

                        // acquire existing plmval
                        temp_plmval = int2fp<TYPE, WORD_SIZE>(
                            plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                        if ((window == 0) && (neuron == 0) && (in == 0)) {
                            ESP_REPORT_INFO("before %.8f", temp_plmval);
                        }
                        // compute (FP) increment
/*
                        temp_incr = int2fp<TYPE, WORD_SIZE>(dW1[window_offset_dW1
                                + neuron*input_dimension + in]) *
                            ((TYPE)0.01);
*/
                        temp_incr = int2fp<TYPE, WORD_SIZE>(dW1[window_offset_dW1
                                + neuron*input_dimension + in]) * ((TYPE)0.01);
/*
                        // artificially ensure that increment never exceeds 1 in absolute value
                        while ((temp_incr > ((TYPE)1.0)) || (temp_incr < ((TYPE)-1.0))) {
                            if ((window == 0) && (neuron == 0) && (in == 0)) {
                                ESP_REPORT_INFO("tempincrement %.8f", -1.0*temp_incr);
                            }
                            temp_incr = temp_incr * ((TYPE)0.1);
                        }
                        temp_incr = temp_incr * ((TYPE)0.05);
*/
                        if ((window == 0) && (neuron == 0) && (in == 0)) {
                            ESP_REPORT_INFO("increment %.8f", -1.0*temp_incr);
                        }
                        // update plmval
                        plm_out[window_offset_weights1 + neuron*input_dimension + in] = 
                            fp2int<TYPE, WORD_SIZE>(temp_plmval - temp_incr);

                        // for testing
                        temp_plmval = int2fp<TYPE, WORD_SIZE>(
                            plm_out[window_offset_weights1 + neuron*input_dimension + in]);
                        if ((window == 0) && (neuron == 0) && (in == 0)) {
                            ESP_REPORT_INFO("after %.8f", temp_plmval);
                        }

/*
                        // add to weight normalization
                        norm +=
                            int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights1 +
                                neuron*input_dimension + in]) *
                            int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights1 +
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
                        fp2int<TYPE, WORD_SIZE>(int2fp<TYPE, WORD_SIZE>(
                            plm_out[window_offset_biases1 + neuron]) / bias_norm);
                    
                    // weight normalization
                    for (uint32_t in = 0; in < input_dimension; in++) {

                        plm_out[window_offset_weights1 + neuron*input_dimension + in] =
                            fp2int<TYPE, WORD_SIZE>(int2fp<TYPE, WORD_SIZE>(
                                plm_out[window_offset_weights1 + neuron*input_dimension + in]) / norm);
                    }
                }

                norm = (TYPE)0.0;
                bias_norm = (TYPE)0.0;
                */

                for (uint32_t out = 0; out < output_dimension; out++) {
                    
                    // update B2

                    // acquire existing plmval
                    temp_plmval = int2fp<TYPE, WORD_SIZE>(
                        plm_out[window_offset_biases2 + out]);
                    // compute (FP) increment
                    temp_incr = int2fp<TYPE, WORD_SIZE>(dB2[window_offset_output + out]) *
                        ((TYPE)0.01);
/*
                    while ((temp_incr > ((TYPE)1.0)) || (temp_incr < ((TYPE)-1.0))) {
                        temp_incr = temp_incr * ((TYPE)0.1);
                    }
                    temp_incr = temp_incr * ((TYPE)0.05);
*/
                    // update plmval
                    plm_out[window_offset_biases2 + out] = 
                        fp2int<TYPE, WORD_SIZE>(temp_plmval - temp_incr);

/*
                    // add to bias normalization
                    bias_norm += int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_biases2 + out]) *
                        int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_biases2 + out]);
*/

                    // update W2
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {


                        // acquire existing plmval
                        temp_plmval = int2fp<TYPE, WORD_SIZE>(
                            plm_out[window_offset_weights2 + out*layer1_dimension + neuron]);
                        // compute (FP) increment
                        temp_incr = int2fp<TYPE, WORD_SIZE>(dW2[window_offset_dW2
                                + out*layer1_dimension + neuron]) *
                            ((TYPE)0.01);
/*
                        while ((temp_incr > ((TYPE)1.0)) || (temp_incr < ((TYPE)-1.0))) {
                            temp_incr = temp_incr * ((TYPE)0.1);
                        }
                        temp_incr = temp_incr * ((TYPE)0.05);
*/
                        // update plmval
                        plm_out[window_offset_weights2 + out*layer1_dimension + neuron] =
                            fp2int<TYPE, WORD_SIZE>(temp_plmval - temp_incr);

/*
                        // add to weight normalization
                        norm +=
                            int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights2 +
                                out*layer1_dimension + neuron]) *
                            int2fp<TYPE, WORD_SIZE>(plm_out[window_offset_weights2 +
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
                        fp2int<TYPE, WORD_SIZE>(int2fp<TYPE, WORD_SIZE>(
                            plm_out[window_offset_biases2 + out]) / bias_norm);
                    
                    // weight normalization
                    for (uint32_t neuron = 0; neuron < layer1_dimension; neuron++) {

                        plm_out[window_offset_weights2 + out*layer1_dimension + neuron] =
                            fp2int<TYPE, WORD_SIZE>(int2fp<TYPE, WORD_SIZE>(
                                plm_out[window_offset_weights2 + out*layer1_dimension + neuron]) / norm);
                    }
                }
                */
            }
            // this window is now complete
        }
        // this epoch is now complete
    }
    // all epochs complete
}
