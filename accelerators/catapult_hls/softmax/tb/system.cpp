// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"

// Process
void system_t::config_proc()
{

    // Reset
    {
        conf_done.write(false);
        conf_info.write(conf_info_t());
        wait();
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "reset done");

    // Config
    load_memory();
    {
        conf_info_t config;
        config.size = 16;

        wait(); conf_info.write(config);
        conf_done.write(true);

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "config(): config.size = %d", config.size);
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(VON, begin_time, "run softmax: BEGIN");

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "waiting for acc_done");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();
        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(VON, end_time, "run softmax: END");

        ESP_REPORT_TIME(VON, sc_time_stamp(), "debug code: %u", debug_code);

        wait(); conf_done.write(false);
    }

    // Validate
    {
        out = new uint32_t[MEM_SIZE];
        dump_memory(); // store the output in more suitable data structure if needed
        // check the results with the golden model
        if (validate())
        {
            ESP_REPORT_TIME(VON, sc_time_stamp(), "validation: FAIL");
        } else
        {
            ESP_REPORT_TIME(VON, sc_time_stamp(), "validation: PASS");
        }
        delete [] out;
    }

    // Conclude
    {
        sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
    //  Memory initialization:
    //  ==============  ^
    //  |  in data   |  | batch * size * sizeof(uint32_t)
    //  ==============  v
    //  ==============  ^
    //  |  out data  |  | batch * size * sizeof(uint32_t)
    //  ==============  v

    for (unsigned i = 0; i < MEM_SIZE; i++) {

        FPDATA_IN data = i + 0.25;
        sc_dt::sc_bv<32> data_bv(data.template slc<32>(0));

        mem[i] = data_bv;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "mem[%d] := %X", i, mem[i].to_uint());
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "memory size: %lu", MEM_SIZE);
    ESP_REPORT_TIME(VON, sc_time_stamp(), "load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    for (unsigned i = 0; i < MEM_SIZE; i++) {
        sc_dt::sc_bv<32> data_bv;

        data_bv = mem[i];

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "mem[%d] -> %X", i, ESP_TO_UINT32(mem[i]));

        out[i] = data_bv.to_uint();

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "out[%d] -> %X", i, ESP_TO_UINT32(out[i]));
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "dump memory completed");
}

void softmax_tb(FPDATA_IN (&input)[MEM_SIZE], double (&output)[MEM_SIZE])
{
    double exp_in[MEM_SIZE];
    double sum_exp = 0;
    for (unsigned i = 0; i < MEM_SIZE; i++) {
        exp_in[i] = exp(input[i].to_double());
        sum_exp += exp_in[i];
    }
    for (unsigned i = 0; i < MEM_SIZE; i++) { output[i] = exp_in[i]/sum_exp; }
}


double abs_double(const double &input)
{
    return input < 0 ? -input : input;
}

int system_t::validate()
{
    uint32_t errors = 0;
  
    double allowed_error = 0.001;

    FPDATA_IN data_in[MEM_SIZE];
    double data_golden_out[MEM_SIZE];

    for (unsigned i = 0; i < MEM_SIZE; i++) {
        FPDATA_IN data = i + 0.25;
        data_in[i] = data;
    }

    softmax_tb(data_in, data_golden_out);

    // Get results from memory
    for (unsigned i = 0; i < MEM_SIZE; i++) {

        float gold = data_golden_out[i];

        // Get accelerator results from memory and compare.
        FPDATA_OUT data;
        ac_int<32, false> data_i = out[i].to_uint();
        data.template set_slc(0, data_i);

        // Calculate absolute error
        double error_it = abs_double(data.to_double() - gold);

        if (error_it > allowed_error) {
            ESP_REPORT_TIME(VON, sc_time_stamp(), "[%d]: %f (expected %f)", i, data.to_double(), gold);
            errors++;
        }
    }

    return errors;
}
