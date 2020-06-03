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

    ESP_REPORT_INFO("reset done");

    init_acc_params();

    for (int acc_id = 0; acc_id < 7; acc_id++) {
    load_memory_acc_id(acc_id);
	send_config(acc_id);

        // Compute
	{
	    // Print information about begin time
	    sc_time begin_time = sc_time_stamp();
	    ESP_REPORT_TIME(begin_time, "BEGIN - synth");

	    // Wait the termination of the accelerator
	    do { wait(); } while (!acc_done.read());
	    debug_info_t debug_code = debug.read();

	    // Print information about end time
	    sc_time end_time = sc_time_stamp();
	    ESP_REPORT_TIME(end_time, "END - synth");

	    esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
	    wait(); conf_done.write(false);
	}

	// Validate
	{
	    dump_memory(); // store the output in more suitable data structure if needed
	    // check the results with the golden model
	    int errors = validate_acc_id(acc_id);
        if (errors)
	    {
		ESP_REPORT_ERROR("validation for acc_id %d failed with %d errors!", acc_id, errors);
	    } else
	    {
		ESP_REPORT_INFO("validation passed for acc_id %d!", acc_id);
	    }
	}
    }

    // Conclude
    {
	sc_stop();
    }
}

// Functions
void system_t::init_acc_params()
{
    //in_size, out_size, access_factor, burst_len, cb_Factor, reuse_factor, in_place, patttern, irregular_seed
    // ld_st_ratio, strode_len, offset, wr_data, rd_data
    /*conf_info_t conf0( 1024, 1024, 0, 16, 4, 2, 1, 0, 0x12345678,    1,    0,  0, 0x87654321, 0x89abcdef);
    configs[0] = conf0;
    conf_info_t conf1( 1024,   1024, 0, 16, 4, 2, 1, 1, 0x12345678,   1,    512, 0, 0x87654321, 0x89abcdef);
    configs[1] = conf1;
    conf_info_t conf2( 4096,   2048, 0, 2048, 4, 4, 1, 0, 0x12345678,   2,    0, 0, 0x87654321, 0x89abcdef);
    configs[2] = conf2;
    conf_info_t conf3( 1024, 1024, 0, 512, 2, 1, 1, 0, 0x12345678,    1,    0, 0, 0x87654321, 0x89abcdef);
    configs[3] = conf3;
    conf_info_t conf4( 8192,  1024, 0,  512, 1, 2, 1, 0, 0x12345678,    8,    0, 0, 0x87654321, 0x89abcdef);
    configs[4] = conf4;
    conf_info_t conf5( 4096,  1024, 0,  256, 1, 4, 1, 0, 0x12345678,    4,    0, 0, 0x87654321, 0x89abcdef);
    configs[5] = conf5;
    conf_info_t conf6( 32768,     1024, 0,    4, 1, 1, 1, 1, 0x12345678, 32, 8, 0, 0x87654321, 0x89abcdef);
    configs[6] = conf6;
    conf_info_t conf7( 8192,    1024, 0,    4, 1, 2, 1, 1, 0x12345678, 8, 16, 0, 0x87654321, 0x89abcdef);
    configs[7] = conf7;
    conf_info_t conf8(1024,    1024, 0,    1, 1, 4, 1, 1, 0x12345678,  1,  512, 0, 0x87654321, 0x89abcdef);
    configs[8] = conf8;
    conf_info_t conf9( 1024,   1024, 0,    4, 1, 1, 0, 2, 0x12345678,   1,    0, 0, 0x87654321, 0x89abcdef);
    configs[9] = conf9;
    conf_info_t conf10(16384,   1024, 2,    1, 1, 2, 0, 2, 0x12345678,    4,    0, 0, 0x87654321, 0x89abcdef);
    configs[10] = conf10;
    conf_info_t conf11(16384,   1024, 4,    1, 1, 4, 0, 2, 0x12345678,    1,    0, 0, 0x87654321, 0x89abcdef);
    configs[11] = conf11;*/
    conf_info_t conf0( 16384, 8192, 0, 4, 16, 2, 1, 0, 0x12345678,    1,    0,  0, 0x87654321, 0x89abcdef);
    configs[0] = conf0;
    conf_info_t conf1( 8192,   8192, 0, 4, 32, 4, 1, 0, 0x12345678,   1,    0, 0, 0x87654321, 0x89abcdef);
    configs[1] = conf1;
    conf_info_t conf2( 8192,   8192, 0, 4, 2, 2, 1, 1, 0x12345678,   1,    128, 0, 0x87654321, 0x89abcdef);
    configs[2] = conf2;
    conf_info_t conf3( 8192, 8192, 0, 4, 32, 4, 1, 1, 0x12345678,    1,    256, 0, 0x87654321, 0x89abcdef);
    configs[3] = conf3;
    conf_info_t conf4( 8192,  8192, 0,  4, 16, 8, 1, 1, 0x12345678,    1,    64, 0, 0x87654321, 0x89abcdef);
    configs[4] = conf4;
    conf_info_t conf5( 8192,  8192, 0,  4, 4, 16, 1, 1, 0x12345678,    1,    32, 0, 0x87654321, 0x89abcdef);
    configs[5] = conf5;
    conf_info_t conf6( 8192,  8192, 0,  128, 1, 32, 1, 1, 0x12345678,    1,  256, 0, 0x87654321, 0x89abcdef);
    configs[6] = conf6;

}
void system_t::load_memory(){

}

void system_t::load_memory_acc_id(int acc_id)
{
    for (int i = 0; i < configs[acc_id].in_size; i++)
    {
        mem[i] = configs[acc_id].rd_data;
    }

}


void system_t::send_config(int acc_id)
{
    conf_info_t config;
    // Custom configuration

    wait();
    conf_info.write(configs[acc_id]);
    conf_done.write(true);

    ESP_REPORT_INFO("config done");
}

void system_t::dump_memory()
{
    // Get results from memory

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate(){

}

int system_t::validate_acc_id(int acc_id)
{
    uint32_t errors = 0;
    uint32_t offset = 0;
    // Check for mismatches

    if (!configs[acc_id].in_place)
        offset = configs[acc_id].in_size;
  
    for (int j = 0; j < configs[acc_id].out_size; j++){
        int index = offset + j;
        if (j == configs[acc_id].out_size - 1 && mem[index] != configs[acc_id].wr_data){
            ESP_REPORT_INFO("Read errors on %d values\n", mem[index].to_uint());
            errors += mem[index].to_uint();
        }
        else if (j != configs[acc_id].out_size - 1 && mem[index] != configs[acc_id].wr_data){
//            ESP_REPORT_INFO("Write error at %d with value %d\n", index, mem[index].to_uint());
            errors += 1;
        }
    }

    return errors;
}
