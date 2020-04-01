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
        config.tokens = MEM_SIZE / 2 * DMA_BEAT_PER_WORD;
        config.batch = 2;

        wait(); conf_info.write(config);
        conf_done.write(true);

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "config(): config.tokes = %d, config.batch = %d", config.tokens, config.batch);
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(VON, begin_time, "BEGIN - dummy");

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "waiting for acc_done");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();
        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(VON, end_time, "END - dummy");

        ESP_REPORT_TIME(VON, sc_time_stamp(), "debug code %u", debug_code);

#if 0
        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
#endif
        wait(); conf_done.write(false);
    }

    // Validate
    {
        out = new uint64_t[MEM_SIZE / DMA_BEAT_PER_WORD];
        dump_memory(); // store the output in more suitable data structure if needed
        // check the results with the golden model
        if (validate())
        {
            ESP_REPORT_TIME(VON, sc_time_stamp(), "validation failed!");
        } else
        {
            ESP_REPORT_TIME(VON, sc_time_stamp(), "validation passed!");
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
    //  |  in data   |  | batch * tokens * sizeof(uint64_t)
    //  ==============  v
    //  ==============  ^
    //  |  out data  |  | batch * tokens * sizeof(uint64_t)
    //  ==============  v

    for (unsigned i = 0; i < MEM_SIZE / DMA_BEAT_PER_WORD; i++) {

        uint64_t data = 0xfeed0bac00000000L | (uint64_t) i;
        sc_dt::sc_bv<64> data_bv(data);

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++) {
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "mem[%d] := %llX", DMA_BEAT_PER_WORD * i + j, mem[DMA_BEAT_PER_WORD * i + j].to_uint64());
        }
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    for (unsigned i = 0; i < MEM_SIZE / DMA_BEAT_PER_WORD; i++) {
        sc_dt::sc_bv<64> data_bv;

        for (unsigned j = 0; j < DMA_BEAT_PER_WORD; j++) {
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) = mem[DMA_BEAT_PER_WORD * i + j];

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "mem[%d] -> %llX", DMA_BEAT_PER_WORD * i + j, mem[DMA_BEAT_PER_WORD * i + j].to_uint64());
        }
        out[i] = data_bv.to_uint64();

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "out[%d] -> %llX", i, out[i]);
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "dump memory completed");
}

int system_t::validate()
{
    uint32_t errors = 0;

    // Check for mismatches
    for (unsigned i = 0; i < MEM_SIZE / DMA_BEAT_PER_WORD; i++) {
        uint64_t expected = (0xfeed0bac00000000L | (uint64_t) (i+1));
        if (out[i] != expected) {
            ESP_REPORT_TIME(VON, sc_time_stamp(), "[%d]: %llX (expected %llX)", i, out[i], expected);
            errors++;
        }
    }

    return errors;
}
