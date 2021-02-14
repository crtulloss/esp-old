// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <iomanip>
#include "system.hpp"

using namespace std;

// Process
void system_t::config_proc()
{

    // Reset
    {
        conf_done.write(false);
        conf_info.write(conf_info_t());
        wait();
    }

    ESP_REPORT_INFO("reset done");

    // Config
    load_memory();
    {
        conf_info_t config;
        // Custom configuration
        /* <<--params-->> */
        config.window_size = window_size;
        config.batches_perload = batches_perload;
        config.learning_rate = a_write(learning_rate);
        config.hiddens_perwin = hiddens_perwin;
        config.tsamps_perbatch = tsamps_perbatch;
        config.num_windows = num_windows;
        config.iters_perbatch = iters_perbatch;
        config.num_loads = num_loads;
        config.rate_mean = a_write(rate_mean);
        config.rate_variance = a_write(rate_variance);
        config.do_init = do_init;
        config.do_backprop = do_backprop;
        config.do_thresh_update = do_thresh_update;

        wait(); conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");
#ifdef split_LR
    ESP_REPORT_INFO("learning rate location A is %.15f", (float)shift_A);
    ESP_REPORT_INFO("learning rate location B is %.15f", (float)learning_rate);
    ESP_REPORT_INFO("learning rate location C is %.15f", (float)shift_down_C);
    ESP_REPORT_INFO("learning rate overall    is %.15f", (float)(shift_A * learning_rate * shift_down_C));
    
#else
    ESP_REPORT_INFO("learning rate is %.15f", (float)learning_rate);
#endif

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - mindfuzz");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - mindfuzz");

        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
        wait(); conf_done.write(false);
    }

    // Validate
    {
        const float ERROR_COUNT_TH = 0.0;
        int num_weights = num_windows*(hiddens_perwin*(window_size+1) + window_size*(hiddens_perwin+1));
        dump_memory(); // store the output in more suitable data structure if needed
        // check the results with the golden model
        if (validate() > ERROR_COUNT_TH)
        {
            ESP_REPORT_ERROR("some errors too great: validation failed!");
        } else
        {
            ESP_REPORT_INFO("all errors within bound: validation passed!");
        }
    }

    // Conclude
    {
        sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
    // Optional usage check
#ifdef CADENCE
    if (esc_argc() != 1)
    {
        ESP_REPORT_INFO("usage: %s\n", esc_argv()[0]);
        sc_stop();
    }
#endif

    // Input data and golden output (aligned to DMA_WIDTH makes your life easier)
#if (DMA_WORD_PER_BEAT == 0)
    in_words_adj = num_windows*window_size*tsamps_perbatch*batches_perload;
    out_words_adj = num_windows*hiddens_perwin*window_size;
#else
    in_words_adj = round_up(num_windows*window_size*tsamps_perbatch*batches_perload, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(num_windows*hiddens_perwin*window_size, DMA_WORD_PER_BEAT);
#endif

    in_size = in_words_adj * (num_loads);
    // edited bc output only at end, not related to batchign
    out_size = out_words_adj;


    // read input data into 2D array from CSV file
#if (FX_WIDTH == 16)
    std::ifstream indata("../sw/m2/float16/data.csv");
#else // 32
    std::ifstream indata("../sw/m2/data_32.csv");
#endif
    std::string line;
    std::vector<std::vector<std::string> > parsedCSV;
    while (std::getline(indata, line)) {
        std::stringstream lineStream(line);
        std::string cell;
        std::vector<std::string> parsedRow;
        while (std::getline(lineStream, cell, ',')) {
            parsedRow.push_back(cell);
        }

        parsedCSV.push_back(parsedRow);
    }

    ESP_REPORT_INFO("input CSV read");

    // temporary float array to store the input data
    in = new float[in_size];

    // dimensions of data relative to CSV 2D
    // in_size = num_loads * batches_perload * tsamps_perbatch *  // num rows
    //           num_windows * window_size                        // num cols

    ESP_REPORT_INFO("in size is %d", in_size);

    for (uint32_t row = 0; row < num_loads*batches_perload*tsamps_perbatch; row++) {

        uint32_t row_offset = row * num_windows * window_size;

        for (uint32_t col = 0; col < num_windows*window_size; col++) {

            // acquire 2D array element
            // there is one extra header row in the CSV
            // and one extra timestamp column
            // add one to indices to ignore these
            std::string element = parsedCSV[row+1][col+1];

            // convert string to float
            stringstream sselem(element);
            float float_element = 0;
            sselem >> float_element;
#if (FX_WIDTH == 16)
            // pre-scale the input data to fit better in fixed-point type
            float_element /= 16;
#endif

            // put it in the array
            in[row_offset + col] = float_element;
        }
    }

    ESP_REPORT_INFO("input transferred to array");

    // read output (weight) data from CSV file into 2D array
    // I concatenated all the data into one file
#if (FX_WIDTH == 16)
    std::ifstream wdata("../sw/m2/float16/h.csv");
#else // 32
    std::ifstream wdata("../sw/m2/h.csv");
#endif
    std::string wline;
    std::vector<std::vector<std::string> > parsed_weights;
    while (std::getline(wdata, wline)) {
        std::stringstream lineStream(wline);
        std::string cell;
        std::vector<std::string> parsedRow;
        while(std::getline(lineStream, cell, ',')) {
            parsedRow.push_back(cell);
        }

        parsed_weights.push_back(parsedRow);
    }

    ESP_REPORT_INFO("output CSV read");

    ESP_REPORT_INFO("out size is %d", out_size);

    // if out_size is odd, out_size will be too large for this loop
    uint32_t out_size_unround =
        num_windows*hiddens_perwin*window_size;

    ESP_REPORT_INFO("out size (unrounded is %d", out_size_unround);

    // temporary float array to store the golden output data
    gold = new float[out_size];

    // need this because still need to know the size of the csv array
    // even if not using all loads in an experiment.
    uint32_t total_loads = 223;

    for (uint32_t hidden = 0; hidden < hiddens_perwin; hidden++) {

        for (uint32_t electrode = 0; electrode < window_size; electrode++) {

            // rows to skip: total loads and header row for previous hiddens
            // row to get from this hidden: num_loads - 1 + 1
            // -1 because 1 load would be load #0,
            // +1 because we skip the header row
            std::string element = parsed_weights[hidden*(total_loads+1) + num_loads][electrode + 1];
        
            // convert string to float
            stringstream sselem(element);
            float float_element = 0;
            sselem >> float_element;
            
            // put it in the array
            gold[hidden*window_size + electrode] = float_element;
        }
    }
    
    ESP_REPORT_INFO("output transferred to array");

    // Memory initialization:
#if (DMA_WORD_PER_BEAT == 0)
    for (int i = 0; i < in_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv(fp2bv<TYPE, WORD_SIZE>(TYPE(in[i])));
        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] =
                data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
#else
    for (int i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv;
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
                fp2bv<TYPE, WORD_SIZE>(TYPE(in[i * DMA_WORD_PER_BEAT + j]));
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    out = new float[out_size];
    uint32_t offset = in_size;

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (int i = 0; i < out_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++) {
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) =
                mem[offset + DMA_BEAT_PER_WORD * i + j];
        }

        TYPE out_fx = bv2fp<TYPE, WORD_SIZE>(data_bv);
        out[i] = (float) out_fx;
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++) {
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            TYPE out_fx = bv2fp<TYPE, WORD_SIZE>(mem[offset + i].range(
                (j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH));
            out[i * DMA_WORD_PER_BEAT + j] = (float) out_fx;
        }
    }
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    // Check for mismatches
    uint32_t errors = 0;
    const float ERR_TH = 0.05;

    // note that this will not be affected by rounding
    int num_weights = num_windows*hiddens_perwin*window_size;

    for (int j = 0; j < num_weights; j++) {
        ESP_REPORT_INFO("index %d:\tgold %0.16f\tout %0.16f\n", j, gold[j], out[j]);
        if ((fabs(gold[j] - out[j]) / fabs(gold[j])) > ERR_TH) {
            errors++;
        }
        else {
            ESP_REPORT_INFO("close enough!\n");
        }
    }

    ESP_REPORT_INFO("Relative error > %0.02f for %d output weights out of %d\n",
        ERR_TH, errors, num_weights);

    delete [] in;
    delete [] out;
    delete [] gold;

    return errors;
}
