// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <random>
#include <sstream>
#include "system.hpp"

static const unsigned char PARTAB[256] = {
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
}; 

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
        config.cbps = cbps;
        config.ntraceback = ntraceback;
        config.data_bits = data_bits;

        wait(); conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - vitdecoder");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - vitdecoder");

        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
        wait(); conf_done.write(false);
    }

    // Validate
    {
        dump_memory(); // store the output in more suitable data structure if needed
        // check the results with the golden model
        if (validate())
        {
            ESP_REPORT_ERROR("validation failed!");
        } else
        {
            ESP_REPORT_INFO("validation passed!");
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
    in_words_adj = 24852;
    out_words_adj = 18585;
#else
    in_words_adj = round_up(24852, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(18585, DMA_WORD_PER_BEAT);
#endif

    in_size = in_words_adj * (1);
    out_size = out_words_adj * (1);

    goldMem = new int8_t[in_size+out_size];
    testMem = new int8_t[in_size+out_size];

    int mi = 0;
    unsigned char depunct_ptn[6] = {1, 1, 0, 0, 0, 0}; // PATTERN_1_2 Extended with zeros

    ESP_REPORT_INFO("Reading in the Mem\n");
    {
        int imi = 0;
        int polys[2] = { 0x6d, 0x4f };
        for(int i=0; i < 32; i++) {
            goldMem[imi] = (polys[0] < 0) ^ PARTAB[(2*i) & abs(polys[0])] ? 1 : 0;
            goldMem[imi+32] = (polys[1] < 0) ^ PARTAB[(2*i) & abs(polys[1])] ? 1 : 0;
            imi++;
        }
        if (imi != 32) { ESP_REPORT_INFO("ERROR : imi = %u and should be 32\n", imi); }
        imi += 32;

        //ESP_REPORT_INFO("Set up brtab27\n");
        if (imi != 64) { ESP_REPORT_INFO("ERROR : imi = %u and should be 64\n", imi); }
        // imi = 64;
        for (int ti = 0; ti < 6; ti ++) {
            goldMem[imi++] = depunct_ptn[ti];
        }
        //ESP_REPORT_INFO("Set up depunct\n");
        goldMem[imi++] = 0;
        goldMem[imi++] = 0;
        if (imi != 72) { ESP_REPORT_INFO("ERROR : imi = %u and should be 72\n", imi); }
        // imi = 72
        //ESP_REPORT_INFO("Set up padding\n");

        gold_in = &goldMem[imi]; // new int8_t[in_size];
        for (int j = imi; j < in_size; j++) {
            int bval = gen_random_bit(); // & 0x01;
            //ESP_REPORT_INFO("Setting up goldMem[%d] = %d\n", j, bval);
            goldMem[j] = bval;
        }
        //ESP_REPORT_INFO("Set up inputs\n");

        gold_out = &goldMem[imi];
        gold = gold_out;
        for (int j = in_size; j < (in_size + out_size); j++)
            goldMem[j] = 0;
        //ESP_REPORT_INFO("Set up outputs\n");
    }

    // Compute the gold output in software!
    ESP_REPORT_INFO("Computing Gold output\n");
    do_decoding(data_bits, cbps, ntraceback, (unsigned char *)goldMem);

    // Copy gold output into "gold"
    //ESP_REPORT_INFO("Copying over Gold Gold output\n");
    gold = new int8_t[out_size];
    for (int j = 0; j < out_size; j++)
        gold[j] = gold_out[j];
    //gold = gold_out;

    // Set up the testMem
    ESP_REPORT_INFO("Setting up testMem\n");
    {
        int imi = 0;
        int polys[2] = { 0x6d, 0x4f };
        for(int i=0; i < 32; i++) {
            testMem[imi] = (polys[0] < 0) ^ PARTAB[(2*i) & abs(polys[0])] ? 1 : 0;
            testMem[imi+32] = (polys[1] < 0) ^ PARTAB[(2*i) & abs(polys[1])] ? 1 : 0;
            imi++;
        }
        if (imi != 32) { ESP_REPORT_INFO("ERROR : imi = %u and should be 32\n", imi); }
        imi += 32;

        //ESP_REPORT_INFO("Set up brtab27\n");
        if (imi != 64) { ESP_REPORT_INFO("ERROR : imi = %u and should be 64\n", imi); }
        // imi = 64;
        for (int ti = 0; ti < 6; ti ++) {
            testMem[imi++] = depunct_ptn[ti];
        }
        //ESP_REPORT_INFO("Set up depunct\n");
        testMem[imi++] = 0;
        testMem[imi++] = 0;
        if (imi != 72) { ESP_REPORT_INFO("ERROR : imi = %u and should be 72\n", imi); }
        // imi = 72
        //ESP_REPORT_INFO("Set up padding\n");

        test_in = &testMem[imi]; // new int8_t[in_size];
        in = test_in;
        for (int j = imi; j < in_size; j++) {
            int bval = gen_random_bit(); // & 0x01;
            //ESP_REPORT_INFO("Setting up testMem[%d] = %d\n", j, bval);
            testMem[j] = bval;
        }
        //ESP_REPORT_INFO("Set up inputs\n");

        test_out = &testMem[imi];
        for (int j = in_size; j < (in_size + out_size); j++)
            testMem[j] = 0;
        //ESP_REPORT_INFO("Set up outputs\n");
    }

    // Memory initialization:
#if (DMA_WORD_PER_BEAT == 0)
    for (int i = 0; i < in_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
#else
    for (int i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) = in[i * DMA_WORD_PER_BEAT + j];
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    out = new int8_t[out_size];
    uint32_t offset = in_size;

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (int i = 0; i < out_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) = mem[offset + DMA_BEAT_PER_WORD * i + j];

        out[i] = data_bv.to_int64();
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++)
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
            out[i * DMA_WORD_PER_BEAT + j] = mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH).to_int64();
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    // Check for mismatches
    uint32_t errors = 0;

    for (int j = 0; j < out_size; j++) {
        if (gold[j] != out[j]) {
            if (errors < 9) { 
                ESP_REPORT_INFO("  Validation Mismatch : [%d] gold vs gold_out vs out vs test_out = %d vs %d vs %d vs %d", j, gold[j], gold_out[j], out[j], test_out[j]);
            }
            errors++;
        } else if (errors < 9) { 
            ESP_REPORT_INFO("  Validation Compare  : [%d] gold vs gold_out vs out vs test_out = %d vs %d vs %d vs %d", j, gold[j], gold_out[j], out[j], test_out[j]);
        }
    }

    ESP_REPORT_INFO("Validation reports a total of %d errors", errors);

    //delete [] in;
    delete [] out;
    delete [] gold;

    delete [] goldMem;
    delete [] testMem;
    return errors;
}
