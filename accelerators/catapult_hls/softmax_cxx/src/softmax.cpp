// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>
#include <mc_scverify.h>
#include <ac_wait.h>

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void softmax_cxx(
#else
void CCS_BLOCK(softmax_cxx)(
#endif
        debug_info_t &debug,
        conf_info_t conf_info,
        bool conf_done,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl) {

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    bool end = false;
    uint32_t batch = 0;

    // Private Local Memories
    plm_in_t plm_in;
    plm_out_t plm_out;

    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(conf_info.batch));

#pragma hls_unroll no
CONFIG_LOOP:
    do
    {
        ac::wait();
        end = conf_done;
        batch = conf_info.batch;
    } while (!end);

BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());
        dma_read_ctrl.write(dma_read_info);
        ESP_REPORT_INFO(VOFF, "dma_read_ctrl done!");

        dma_read_data_index += dma_read_data_length;

LOAD_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_read_data_length) break;

            // DMA_WIDTH = 64
            // but DATA_WIDTH = 32
            // discard bits in the DMA range(63,32)
            // keep bits in the DMA range(31,0)
            ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

            FPDATA_IN data;
            data.set_slc(0, data_ac);

            plm_in.data[i] = data;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }


        ac_math::ac_softmax_pwl(plm_in.data, plm_out.data);


        // Configure DMA write channle (CTRL)
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());
        dma_write_ctrl.write(dma_write_info);
        ESP_REPORT_INFO(VOFF, "dma_read_ctrl done!");

        dma_write_data_index += dma_write_data_length;

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

            dma_write_chnl.write(data_ac);

            ESP_REPORT_INFO(VOFF, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }

    }

    debug = 0;
}
