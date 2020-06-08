// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>

//
// Compute functions
//

template <class T1, unsigned S1, class T2, unsigned S2>
void compute_wrapper(plm_t<T1,S1> *input, plm_t<T2,S2> *output) {
    ac_math::ac_softmax_pwl(input->data, output->data);
}

//
// Process
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

// ***************************************************
// *** YOU SHOULD NOT EDIT THE FOLLOWING FUNCTIONS ***
// ***************************************************

inline void softmax_sysc::process_done() {
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

inline void softmax_sysc::accelerator_done() {
    acc_done.write(true); wait(); wait(); wait();
    acc_done.write(false);
}
