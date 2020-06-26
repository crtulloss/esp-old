// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "activation.hpp"

#include <ac_math/ac_softmax_pwl.h>
#include <ac_math/ac_tanh_pwl.h>
#include <ac_math/ac_sigmoid_pwl.h>
#include <mc_scverify.h>

template <class T1, class T2>
void compute_wrapper(uint32_t kind, T1 &input, T2 &output) {
    switch (kind) {
        case 0:
            ac_math::ac_softmax_pwl(input.data, output.data);
            break;
        case 1:
            for (unsigned i = 0; i < 128; i++)
                ac_math::ac_tanh_pwl(input.data[i], output.data[i]);
            break;
        case 2:
            for (unsigned i = 0; i < 128; i++)
                ac_math::ac_sigmoid_pwl(input.data[i], output.data[i]);
            break;
        case 3:
            for (unsigned i = 0; i < 128; i++)
                output.data[i] = (input.data[i] >= 0) ? input.data[i] : 0;
            break;
        default:
            ;
    }
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void activation_cxx(
#else
void CCS_BLOCK(activation_cxx)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    uint32_t batch = 0;
    uint32_t kind = 0;

    // Private Local Memories
    plm_in_t plm_in;
    plm_out_t plm_out;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    conf_info_t conf_info_data = conf_info.read();
    batch = conf_info_data.batch;
    kind = conf_info_data.kind;

    ESP_REPORT_INFO(VOFF, "conf_info.batch = %u, conf_info.kind = %u", ESP_TO_UINT32(batch), ESP_TO_UINT32(kind));

BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VOFF, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_read_data_length) break;

                // DMA_WIDTH = 64
                // but DATA_WIDTH = 32
                // discard bits in the DMA range(63,32)
                // keep bits in the DMA range(31,0)
                ac_int<DATA_WIDTH, false> data_ac;
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

                SOFTMAX_FPDATA_IN data;
                data.set_slc(0, data_ac);

                plm_in.data[i] = data;

                ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
            }
        }

        compute_wrapper<plm_in_t, plm_out_t>(kind, plm_in, plm_out);

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_write_data_length * batch) + dma_write_data_length * b;
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
        do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VOFF, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_write_data_length) break;

                SOFTMAX_FPDATA_OUT data = plm_out.data[i];

                // DMA_WIDTH = 64
                // but DATA_WIDTH = 32
                // set to a constante value range(63,32)
                // return results on the range(31,0)
                ac_int<DMA_WIDTH, false> data_ac;
                ac_int<32, false> DEADBEEF = 0xdeadbeef;
                data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
                data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

                dma_write_chnl.write(data_ac);

                ESP_REPORT_INFO(VOFF, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
            }
        }
    }

    acc_done.sync_out();
}
