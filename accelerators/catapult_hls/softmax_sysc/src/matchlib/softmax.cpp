// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>

#include "ArbitratedScratchpadDPTop.h"

//
// Compute functions
//

template <class T1, unsigned S1, class T2, unsigned S2>
void compute_wrapper(const T1 input[S1], const T2 output[S2]) {
    ac_math::ac_softmax_pwl(input, output);
}

//
// Processes
//
#pragma design modulario<sync>
void softmax_sysc::config() {

    done.write(false);
    wait();

    // Wait for the configuration signal
#pragma hls_unroll no
CONFIG_LOOP:
    do
    {
        wait();
    } while (!conf_done.read());

    // Configuration completed
    done.write(true);

#pragma hls_unroll no
CONFIG_DONE_LOOP:
    while (true) { wait(); }
}

void softmax_sysc::load() {

    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t batch = 0;
    reset_load_input();
    debug = 0;
    wait();

    // Load-process config
    wait_for_config();
    conf_info_t config = conf_info.read();
    batch = config.batch;

    ESP_REPORT_TIME(VON, sc_time_stamp(), "load_input(): LOAD_BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));
    ESP_REPORT_TIME(VON, sc_time_stamp(), "load_input():    LOAD_LOOP = %u", PLM_SIZE);

    // Load-process body
LOAD_BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_info_t dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        dma_read_ctrl.Push(dma_read_info);
        ESP_REPORT_TIME(VON, sc_time_stamp(), "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        bool complete = false;
LOAD_LOOP:
        for(uint32_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_read_data_length) break;

            // DMA_WIDTH = 64
            // but DATA_WIDTH = 32
            // discard bits in the DMA range(63,32)
            // keep bits in the DMA range(31,0)
            ac_int<DATA_WIDTH, false> data_ac;

            data_ac = dma_read_chnl.Pop().template slc<DATA_WIDTH>(0);

            FPDATA_IN data;
            data.set_slc(0, data_ac);


            Address read_address[kNumReadPorts];
            bool read_req_valid[kNumReadPorts];
            Address write_address[kNumWritePorts];
            bool write_req_valid[kNumWritePorts];
            FPDATA_IN write_data[kNumWritePorts];
            bool read_ack[kNumReadPorts];
            bool write_ack[kNumWritePorts];
            FPDATA_IN port_read_out[kNumReadPorts];
            bool port_read_out_valid[kNumReadPorts];

            write_address[0] = (Address)i;
            write_req_valid[0] = true;
            write_data[0] = data;

            write_address[1] = 0;
            write_req_valid[1] = false;
            write_data[1] = 0;

#pragma hls_unroll no
LOAD_ARBITER_COMPLETE_LOOP:
            while (!complete) {
                ArbitratedScratchpadDPTop<FPDATA_IN>(read_address, read_req_valid, write_address, write_req_valid, write_data, read_ack, write_ack, port_read_out, port_read_out_valid);
                complete = true;
                if (write_req_valid[0] == true) {
                    if (!write_ack[0]) {
                        complete = false;
                    } else {
                        write_req_valid[0] = false;
                    }
                }
            }
            complete = false;
        }
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load() --> compute() WAIT");

        load_compute_handshake();

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load() --> compute()");
    }

    // Load-process done
    process_done();
}

void softmax_sysc::compute() {
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t dma_write_data_length = PLM_SIZE;
    uint32_t batch = 0;
    reset_compute_kernel();
    wait();

    // Compute-process config
    wait_for_config(); // config process
    conf_info_t config = conf_info.read();
    batch = config.batch;

    ESP_REPORT_TIME(VON, sc_time_stamp(), "compute_kernel(): COMPUTE_BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));

    // Compute-process body
COMPUTE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {

        compute_load_handshake();
        ESP_REPORT_TIME(VON, sc_time_stamp(), "Compute compute() <---> load()");

        // Required to create shared memories
        FPDATA_IN plm_tmp_in[PLM_SIZE];
        FPDATA_OUT plm_tmp_out[PLM_SIZE];

        bool complete = false;
COMPUTE_DATA_IN_LOOP:
        for (uint32_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_read_data_length) break;

            FPDATA_IN data;

            Address read_address[kNumReadPorts];
            bool read_req_valid[kNumReadPorts];
            Address write_address[kNumWritePorts];
            bool write_req_valid[kNumWritePorts];
            FPDATA_IN plm_in_write_data[kNumWritePorts];
            FPDATA_OUT plm_out_write_data[kNumWritePorts];
            bool read_ack[kNumReadPorts];
            bool write_ack[kNumWritePorts];
            FPDATA_IN plm_in_port_read_out[kNumReadPorts];
            FPDATA_OUT plm_out_port_read_out[kNumReadPorts];
            bool port_read_out_valid[kNumReadPorts];

            read_address[0] = 0;
            read_req_valid[0] = false;
            plm_in_port_read_out[0] = 0;
            port_read_out_valid[0] = 0;

            read_address[1] = (Address)i;
            read_req_valid[1] = true;
            plm_in_port_read_out[1] = 0;
            port_read_out_valid[1] = 0;

#pragma hls_unroll no
COMPUTE_DATA_IN_ARBITER_COMPLETE_LOOP:
            while (!complete) {
                complete = true;
                ArbitratedScratchpadDPTop<FPDATA_IN>(read_address, read_req_valid, write_address, write_req_valid, plm_in_write_data, read_ack, write_ack, plm_in_port_read_out, port_read_out_valid);

                data = plm_in_port_read_out[1];

                if (read_req_valid[1] == true) {
                    if(!read_ack[1]) {
                        complete = false;
                    } else {
                        read_req_valid[1] = false;
                    }
                }
            }
            complete = false;

            plm_tmp_in[i] = data;
        }

        ac_math::ac_softmax_pwl(plm_tmp_in, plm_tmp_out);

        complete = false;
COMPUTE_DATA_OUT_LOOP:
        for(uint32_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_write_data_length) break;

            FPDATA_OUT data = plm_tmp_out[i];

            Address read_address[kNumReadPorts];
            bool read_req_valid[kNumReadPorts];
            Address write_address[kNumWritePorts];
            bool write_req_valid[kNumWritePorts];
            FPDATA_OUT plm_out_write_data[kNumWritePorts];
            bool read_ack[kNumReadPorts];
            bool write_ack[kNumWritePorts];
            FPDATA_OUT plm_out_port_read_out[kNumReadPorts];
            bool port_read_out_valid[kNumReadPorts];

            write_address[0] = (Address)i;
            write_req_valid[0] = true;
            plm_out_write_data[0] = data;

            write_address[1] = 0;
            write_req_valid[1] = false;
            plm_out_write_data[1] = 0;

#pragma hls_unroll no
COMPUTE_DATA_OUT_ARBITER_COMPLETE_LOOP:
            while (!complete) {
                ArbitratedScratchpadDPTop<FPDATA_OUT>(read_address, read_req_valid, write_address, write_req_valid, plm_out_write_data, read_ack, write_ack, plm_out_port_read_out, port_read_out_valid);
                complete = true;
                if (write_req_valid[0] == true) {
                    if (!write_ack[0]) {
                        complete = false;
                    } else {
                        write_req_valid[0] = false;
                    }
                }
            }
            complete = false;
        }

        compute_store_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() ---> store()");
    }

    // Compute-process done
    process_done();
}

void softmax_sysc::store() {

    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;
    uint32_t batch = 0;
    reset_store_output();
    wait();

    // Store-process config
    wait_for_config();
    conf_info_t config = conf_info.read();
    batch = config.batch;

    ESP_REPORT_TIME(VON, sc_time_stamp(), "store_output(): STORE_BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));
    ESP_REPORT_TIME(VON, sc_time_stamp(), "store_output():    STORE_LOOP = %u", PLM_SIZE);

    // Store-process body
STORE_BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {
        if (b >= batch) break;

        store_compute_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store() --> compute()");

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_write_data_length * batch) + dma_write_data_length * b;
        dma_info_t dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());
        dma_write_ctrl.Push(dma_write_info);

        bool complete = false;
STORE_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_write_data_length) break;

            FPDATA_OUT data;

            Address read_address[kNumReadPorts];
            bool read_req_valid[kNumReadPorts];
            Address write_address[kNumWritePorts];
            bool write_req_valid[kNumWritePorts];
            FPDATA_OUT write_data[kNumWritePorts];
            bool read_ack[kNumReadPorts];
            bool write_ack[kNumWritePorts];
            FPDATA_OUT port_read_out[kNumReadPorts];
            bool port_read_out_valid[kNumReadPorts];

            read_address[0] = 0;
            read_req_valid[0] = false;
            port_read_out[0] = 0;
            port_read_out_valid[0] = 0;

            read_address[1] = (Address)i;
            read_req_valid[1] = true;
            port_read_out[1] = 0;
            port_read_out_valid[1] = 0;

#pragma hls_unroll no
STORE_ARBITER_COMPLETE_LOOP:
            while (!complete) {
                complete = true;
                ArbitratedScratchpadDPTop<FPDATA_OUT>(read_address, read_req_valid, write_address, write_req_valid, write_data, read_ack, write_ack, port_read_out, port_read_out_valid);

                data = port_read_out[1];

                if (read_req_valid[1] == true) {
                    if(!read_ack[1]) {
                        complete = false;
                    } else {
                        read_req_valid[1] = false;
                    }
                }
            }
            complete = false;

            // DMA_WIDTH = 64
            // but DATA_WIDTH = 32
            // set to a constante value range(63,32)
            // return results on the range(31,0)
            ac_int<DMA_WIDTH, false> data_ac;
            ac_int<32, false> DEADBEEF = 0xdeadbeef;
            data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
            data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

            dma_write_chnl.Push(data_ac);
        }
    }

    accelerator_done();
    process_done();
}

// ***************************************************
// *** YOU SHOULD NOT EDIT THE FOLLOWING FUNCTIONS ***
// ***************************************************

//
// Reset functions
//

inline void softmax_sysc::reset_dma_read() {
    dma_read_ctrl.Reset();
    dma_read_chnl.Reset();
}

inline void softmax_sysc::reset_dma_write() {
    dma_write_ctrl.Reset();
    dma_write_chnl.Reset();
}

inline void softmax_sysc::reset_accelerator_done() {
    acc_done.write(false);
}

//
// Functions
//

inline void softmax_sysc::reset_load_input() {
    input_ready.reset_req();
    reset_dma_read();
}

inline void softmax_sysc::reset_compute_kernel() {
    input_ready.reset_ack();
    output_ready.reset_req();
}

inline void softmax_sysc::reset_store_output() {
    reset_accelerator_done();
    reset_dma_write();
    output_ready.reset_ack();
}

inline void softmax_sysc::load_compute_handshake() {
    input_ready.req();
}

inline void softmax_sysc::compute_load_handshake() {
    input_ready.ack();
}

inline void softmax_sysc::compute_store_handshake() {
    output_ready.req();
}

inline void softmax_sysc::store_compute_handshake() {
    output_ready.ack();
}

inline void softmax_sysc::wait_for_config() {
#pragma hls_unroll no
WAIT_FOR_CONFIG_LOOP:
    while (!done.read()) { wait(); }
}

inline void softmax_sysc::process_done() {
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

inline void softmax_sysc::accelerator_done() {
    acc_done.write(true); wait(); wait(); wait();
    acc_done.write(false);
}
