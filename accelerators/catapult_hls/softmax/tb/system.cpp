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
        config.batch = BATCH;

        wait(); conf_info.write(config);
        conf_done.write(true);

        ESP_REPORT_TIME(VON, sc_time_stamp(), "config.batch = %d", config.batch);
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

        ESP_REPORT_TIME(VON, sc_time_stamp(), "debug code = %u", debug_code);

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

    for (unsigned i = 0; i < BATCH*SIZE; i++) {

        FPDATA_IN data = (i % 32) + 0.25;

        sc_dt::sc_bv<DMA_WIDTH> data_bv;
        data_bv.range(63,32) = sc_dt::sc_bv<32>(0xdeadbeef);
        data_bv.range(31,0) = (data.template slc<32>(0));
        //std::cout << std::hex << data_bv.range(63,32).to_uint() << std::dec << "|" << data_bv.range(31,0) << std::endl; 

        mem[i] = data_bv;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "mem[%d] := %X", i, mem[i].to_uint());
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "memory size: %lu", MEM_SIZE);
    ESP_REPORT_TIME(VON, sc_time_stamp(), "data-in-memory size: %lu", BATCH*SIZE);
    ESP_REPORT_TIME(VON, sc_time_stamp(), "load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    for (unsigned i = 0; i < BATCH*SIZE; i++) {
        sc_dt::sc_bv<DMA_WIDTH> data_bv;

        unsigned offset = BATCH * SIZE;

        data_bv = mem[offset + i];

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "mem[%d] -> %llX", offset + i, mem[offset + i].to_uint64());

        out[offset + i] = data_bv.range(31,0).to_uint();

        //std::cout << "out[" << offset + i << "] = " << out[offset+i] << std::endl;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "out[%d] -> %X", offset + i, ESP_TO_UINT32(out[offset + i]));
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "dump memory completed");
}

#if 0
// Returns approximate value of e^x,
// using sum of first n terms of Taylor Series
static float exponential(int n, float x)
{
    float sum = 1.0f; // initialize sum of series
    int i;
    for (i = n - 1; i > 0; --i )
        sum = 1 + x * sum / i;

    return sum;
}
#endif

void softmax_tb(FPDATA_IN (&input)[SIZE], double (&output)[SIZE])
{
    double exp_in[SIZE];
    double sum_exp = 0;
    for (unsigned i = 0; i < SIZE; i++) {
        exp_in[i] = exp(input[i].to_double());
#if 0
        printf("exp = %f, taylor_exp = %f\n", (float)exp(input[i].to_double()), exponential(100, (float)input[i].to_double()));
#endif
        sum_exp += exp_in[i];
    }
    for (unsigned i = 0; i < SIZE; i++) { output[i] = exp_in[i]/sum_exp; }
}


double abs_double(const double &input)
{
    return input < 0 ? -input : input;
}

int system_t::validate()
{
    uint32_t errors = 0;

    double allowed_error = 0.001;

    for (unsigned b = 0; b < BATCH; b++) {
        FPDATA_IN data_in[SIZE];
        double data_golden_out[SIZE];

        for (unsigned s = 0; s < SIZE; s++) {
            FPDATA_IN data = ((b * SIZE + s) % 32) + 0.25;
            data_in[s] = data;
        }

        softmax_tb(data_in, data_golden_out);

        // Get results from memory
        for (unsigned s = 0; s < SIZE; s++) {

            float gold = data_golden_out[s];

            // Get accelerator results from memory and compare.
            FPDATA_OUT data;
            unsigned index = SIZE * BATCH + b * SIZE + s;
            ac_int<32, false> data_i = ESP_TO_UINT32(out[index]);
            data.template set_slc(0, data_i);

            // Calculate absolute error
            double error_it = abs_double(data.to_double() - gold);

            if (error_it > allowed_error) {
                ESP_REPORT_TIME(VOFF, sc_time_stamp(), "[%lu]: %f (expected %f)", b * SIZE + s, data.to_double(), gold);
                errors++;
            }
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "[%lu] softmax(%f) = %f (expected %f)%s", b * SIZE + s, data_in[s].to_double(), data.to_double(), gold, (error_it > allowed_error) ? ": ERROR" : "");

        }
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "total errors = %u / %lu", ESP_TO_UINT32(errors), BATCH * SIZE);

    return errors;
}
