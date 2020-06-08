// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>
#if 0
//
// Compute functions
//

template <class T1, unsigned S1, class T2, unsigned S2>
void compute_wrapper(plm_t<T1,S1> *input, plm_t<T2,S2> *output) {
    ac_math::ac_softmax_pwl(input->data, output->data);
}

//
// Processes
//
#pragma design modulario<sync>
void softmax_sysc::config() {
    // HLS_DEFINE_PROTOCOL("config");
    done.write(false); wait();
    //ESP_REPORT_INFO("start configuration");
    // Wait for the configuration signal
    bool end = false;

#pragma hls_unroll no
CONFIG_LOOP:
    do
    {
        wait();
        end = conf_done.read();
    } while (!end);

    // Configuration completed
    done.write(true);

    //ESP_REPORT_INFO("end configuration");

#pragma hls_unroll no
CONFIG_DONE_LOOP:
    while (true) { wait(); }
}

void softmax_sysc::load() {

    // Load-process reset
    {
        reset_load_input();
        debug = 0;
        wait();
    }

    // Load-process config
    uint32_t batch;
    {
        wait_for_config(); // config process
        conf_info_t config = conf_info.read();

        batch = config.batch;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load config(): batch = %u", ESP_TO_UINT32(batch));
    }

    uint32_t offset = 0;

    // TODO Disable explicit ping-pong buffering. Does Catapult HLS infer
    // ping-pong buffering on its own?
    //bool ping = true;

    ESP_REPORT_TIME(VON, sc_time_stamp(), "load_input(): LOAD_BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));
    ESP_REPORT_TIME(VON, sc_time_stamp(), "load_input():    LOAD_DATA_INNER_LOOP = %u", PLM_SIZE);

    // Load-process body
LOAD_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {

        dma_info_t dma_info(offset, PLM_SIZE, 3);

        offset += PLM_SIZE;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_info.index = %u, dma_info.length = %u, dma_info.size = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());

        DMA_WRITE(dma_info, dma_read_ctrl);

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_read_ctrl done!");

        plm_t<FPDATA_IN, PLM_SIZE> plm_local;

LOAD_DATA_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            FPDATA_IN data;
            sc_dt::sc_bv<64> data_bv;
            ac_int<32> data_ac;

            DMA_READ(data_bv, dma_read_chnl);

            // DMA_WIDTH = 64
            // discard bits in the range(63,32)
            // keep bits in the range(31,0)
            data_ac = ac_int<32>(data_bv.range(31,0).to_uint());
            data.set_slc(0, data_ac);
            plm_local.data[i] = data;
        }


        //if (ping) {
        //    plm0_in.write(plm_local);
        //} else {
        //    plm1_in.write(plm_local);
        //}
        plm_in.write(plm_local);

        load_compute_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load() --> compute()");
        //ping = !ping;
    }

    // Load-process done
    {
        process_done();
    }
}

void softmax_sysc::compute() {

    // Compute-process reset
    {
        reset_compute_kernel();
        wait();
    }

    // Compute-process config
    uint32_t batch;
    {
        wait_for_config(); // config process
        conf_info_t config = conf_info.read();

        batch = config.batch;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute config(): batch = %u", ESP_TO_UINT32(batch));
    }

    // TODO Disable explicit ping-pong buffering. Does Catapult HLS infer
    // ping-pong buffering on its own?
    //bool ping = true;

    ESP_REPORT_TIME(VON, sc_time_stamp(), "compute_kernel(): COMPUTE_BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));

    // Compute-process body
COMPUTE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {

        compute_load_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() <---> load()");

        plm_t<FPDATA_IN, PLM_SIZE> plm_local_in;
        plm_t<FPDATA_OUT, PLM_SIZE> plm_local_out;

        //if (ping) {
        //    plm_local_in = plm0_in.read();
        //} else {
        //    plm_local_in = plm1_in.read();
        //}
        plm_local_in = plm_in.read();

        compute_wrapper<FPDATA_IN, PLM_SIZE, FPDATA_OUT, PLM_SIZE>(&plm_local_in, &plm_local_out);

        //if (ping) {
        //    plm0_out.write(plm_local_out);
        //} else {
        //    plm1_out.write(plm_local_out);
        //}
        plm_out.write(plm_local_out);

        compute_store_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() ---> store()");

        //ping = !ping;
    }

    // Compute-process done
    {
        process_done();
    }
}

void softmax_sysc::store() {

    // Store-process reset
    {
        reset_store_output();
        wait();
    }

    // Store-process config
    uint32_t batch;
    {
        wait_for_config(); // config process
        conf_info_t config = conf_info.read();

        batch = config.batch;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store config(): batch = %u", ESP_TO_UINT32(batch));
    }

    uint32_t offset = PLM_SIZE * batch;

    // TODO Disable explicit ping-pong buffering. Does Catapult HLS infer
    // ping-pong buffering on its own?
    //bool ping = true;

    ESP_REPORT_TIME(VON, sc_time_stamp(), "store_output(): STORE_BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));
    ESP_REPORT_TIME(VON, sc_time_stamp(), "store_output():    STORE_DATA_INNER_LOOP = %u", PLM_SIZE);

    // Store-process body
STORE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {

            store_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store() --> compute()");

            dma_info_t dma_info(offset, PLM_SIZE, 3);

            offset += PLM_SIZE;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): dma_info.index = %u, dma_info.length = %u, dma_info.size = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());

            DMA_WRITE(dma_info, dma_write_ctrl);

            plm_t<FPDATA_OUT, PLM_SIZE> plm_local;

            //if (ping) {
            //    plm_local = plm0_out.read();
            //} else {
            //    plm_local = plm1_out.read();
            //}
            plm_local = plm_out.read();

STORE_DATA_INNER_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                FPDATA_OUT data = plm_local.data[i];

                // DMA_WIDTH = 64
                // set to a constante value range(63,32)
                // return results on the range(31,0)
                sc_dt::sc_bv<64> data_bv;
                data_bv.range(63,32) = sc_dt::sc_bv<32>(0xdeadbeef);
                data_bv.range(31,0) = data.template slc<32>(0);

                DMA_WRITE(data_bv, dma_write_chnl);
            }


            //ping = !ping;
    }

    // Store-process done
    {
        accelerator_done();
        process_done();
    }
}
#else
//
// Compute functions
//

template <class T1, unsigned S1, class T2, unsigned S2>
void compute_wrapper(plm_t<T1,S1> *input, plm_t<T2,S2> *output) {
    ac_math::ac_softmax_pwl(input->data, output->data);
}

//
// Processes
//
void softmax_sysc::run() {

    dma_read_ctrl.Reset();
    dma_read_chnl.Reset();
    dma_write_ctrl.Reset();
    dma_write_chnl.Reset();
    acc_done.write(false);

    debug = 0;

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;

    uint32_t batch = 0;

    conf_info_t config;

    // Private Local Memories
    plm_in_t plm_in;
    plm_out_t plm_out;

    wait();

    // Wait for the configuration signal
#pragma hls_unroll no
CONFIG_LOOP:
    do
    {
        wait();
        config = conf_info.read();
    } while (!conf_done.read());

    // Load/Compute/Store-process config
    {
        batch = config.batch;
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "BATCH_LOOP: batch = %u", ESP_TO_UINT32(batch));

    dma_read_data_index = 0;

    // Load-process body
BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_info_t dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        dma_read_ctrl.Push(dma_read_info);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

LOAD_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_read_data_length) break;

            // DMA_WIDTH = 64
            // but DATA_WIDTH = 32
            // discard bits in the DMA range(63,32)
            // keep bits in the DMA range(31,0)
            ac_int<DATA_WIDTH, false> data_ac;

            data_ac = dma_read_chnl.Pop().template slc<DATA_WIDTH>(0);

            FPDATA_IN data;
            data.set_slc(0, data_ac);
            plm_in.data[i] = data;
        }

        // Compute-process body
        compute_wrapper<FPDATA_IN, PLM_SIZE, FPDATA_OUT, PLM_SIZE>(&plm_in, &plm_out);

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_write_data_length * batch) + dma_write_data_length * b;
        dma_info_t dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};

        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        dma_write_ctrl.Push(dma_write_info);

        ESP_REPORT_TIME(VON, sc_time_stamp(), "STORE_LOOP = %u", PLM_SIZE);

STORE_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_write_data_length) break;

            FPDATA_OUT data = plm_out.data[i];

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

    // Process done
    {
        accelerator_done();
        process_done();
    }
}
#endif

// ***************************************************
// *** YOU SHOULD NOT EDIT THE FOLLOWING FUNCTIONS ***
// ***************************************************
#if 0
//
// Reset functions
//

inline void softmax_sysc::reset_dma_read() {
    DMA_WRITE_RESET(dma_read_ctrl);
    DMA_READ_RESET(dma_read_chnl);
}

inline void softmax_sysc::reset_dma_write() {
    DMA_WRITE_RESET(dma_write_ctrl);
    DMA_WRITE_RESET(dma_write_chnl);
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
#endif

inline void softmax_sysc::process_done() {
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

inline void softmax_sysc::accelerator_done() {
    acc_done.write(true); wait(); wait(); wait();
    acc_done.write(false);
}
