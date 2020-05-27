// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>
#include <mc_scverify.h>
#include <ac_wait.h>

// TODO: Uncomment this to enable multiprocess.
#if 0

#pragma hls_design
void config(
        conf_info_t &conf_info,
        bool conf_done,
        ac_channel<conf_info_t> &plm_conf_load,
        ac_channel<conf_info_t> &plm_conf_compute,
        ac_channel<conf_info_t> &plm_conf_store) {

    bool end = false;
    unsigned batch = 0;
#pragma hls_unroll no
CONFIG_LOOP:
    do
    {
        ac::wait();
        end = conf_done;
        batch = conf_info.batch;
    } while (!end);

    conf_info_t conf_info_load_tmp;
    conf_info_t conf_info_compute_tmp;
    conf_info_t conf_info_store_tmp;

    conf_info_load_tmp.batch = batch;
    conf_info_compute_tmp.batch = batch;
    conf_info_store_tmp.batch = batch;

    plm_conf_load.write(conf_info_load_tmp);
    plm_conf_compute.write(conf_info_compute_tmp);
    plm_conf_store.write(conf_info_store_tmp);
}

#pragma hls_design
void load(
        ac_channel<conf_info_t> &plm_conf,
        ac_channel<plm_in_t> &plm_in,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl) {

    // Load configuration
    conf_info_t conf_info_tmp = plm_conf.read();
    uint32_t batch = conf_info_tmp.batch;

    // Bookkeeping variables
    uint32_t dma_data_index = 0;
    uint32_t dma_data_length = PLM_SIZE;

LOAD_OUTER_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_info_t dma_info = {dma_data_index, dma_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA data index = %u, DMA data length = %u, DMA size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());
        dma_read_ctrl.write(dma_info);
        ESP_REPORT_INFO(VOFF, "dma_read_ctrl done!");

        // Required to create shared memories
        plm_t<FPDATA_IN, PLM_SIZE> plm_tmp;

LOAD_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_data_length) break;

            // DATA_WIDTH = 64
            // DATA_WIDTH = 32
            // discard bits in the DMA range(63,32)
            // keep bits in the DMA range(31,0)
            ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

            FPDATA_IN data;
            data.set_slc(0, data_ac);

            plm_tmp.data[i] = data;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }

        plm_in.write(plm_tmp);

        ESP_REPORT_INFO(VON, "load() --> compute()");

        dma_data_index += dma_data_length;
    }
}

#pragma hls_design
void compute(
        ac_channel<conf_info_t> &plm_conf,
        ac_channel<plm_in_t> &plm_in,
        ac_channel<plm_out_t> &plm_out) {

    // Compute configuration
    conf_info_t conf_info_tmp = plm_conf.read();

    // Bookkeping variables
    uint32_t batch = conf_info_tmp.batch;

COMPUTE_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        ESP_REPORT_INFO(VOFF, "compute() <---> load()");

        plm_in_t plm_in_tmp;
        plm_out_t plm_out_tmp;

        plm_in_tmp = plm_in.read();

        ac_math::ac_softmax_pwl(plm_in_tmp.data, plm_out_tmp.data);

        plm_out.write(plm_out_tmp);

        ESP_REPORT_INFO(VON, "compute() ---> store()");
    }

}

#pragma hls_design
void store(
        ac_channel<conf_info_t> &plm_conf,
        ac_channel<plm_out_t> &plm_out,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_write_chnl) {

    // Store configuration
    conf_info_t conf_info_tmp = plm_conf.read();
    uint32_t batch = conf_info_tmp.batch;

    // Bookkeping variables
    uint32_t dma_data_index= 0;
    uint32_t dma_data_length = PLM_SIZE;

STORE_OUTER_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        ESP_REPORT_INFO(VON, "store() --> compute()");

        // Configure DMA write channle (CTRL)
        dma_info_t dma_info = {dma_data_index, dma_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA data index = %u, DMA data length = %u, DMA size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());
        dma_write_ctrl.write(dma_info);
        ESP_REPORT_INFO(VOFF, "dma_read_ctrl done!");

        // Required to create shared memories
        plm_t<FPDATA_OUT, PLM_SIZE> plm_tmp = plm_out.read();

STORE_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_data_length) break;

            FPDATA_OUT data = plm_tmp.data[i];

            // DMA_WIDTH = 64
            // DATA_WIDTH = 32
            // set to a constante value range(63,32)
            // return results on the range(31,0)
            ac_int<DMA_WIDTH, false> data_ac;
            ac_int<32, false> DEADBEEF = 0xdeadbeef;
            data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
            data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

            dma_write_chnl.write(data_ac);

            ESP_REPORT_INFO(VOFF, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }

        dma_data_index += dma_data_length;
    }
}

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

    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(conf_info.batch));

    static ac_channel<plm_in_t> plm_in;
    static ac_channel<plm_out_t> plm_out;

    static ac_channel<conf_info_t> plm_conf_load;
    static ac_channel<conf_info_t> plm_conf_compute;
    static ac_channel<conf_info_t> plm_conf_store;

    config(conf_info, conf_done, plm_conf_load, plm_conf_compute, plm_conf_store);

    load(plm_conf_load, plm_in, dma_read_ctrl, dma_read_chnl);
    compute(plm_conf_compute, plm_in, plm_out);
    store(plm_conf_store, plm_out, dma_write_ctrl, dma_write_chnl);

    debug = 0;
}

#else

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

    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(conf_info.batch));

    plm_in_t plm_in;
    plm_out_t plm_out;

    bool end = false;
    uint32_t batch = 0;
#pragma hls_unroll no
CONFIG_LOOP:
    do
    {
        ac::wait();
        end = conf_done;
        batch = conf_info.batch;
    } while (!end);

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;

LOAD_OUTER_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_info_t dma_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());
        dma_read_ctrl.write(dma_info);
        ESP_REPORT_INFO(VOFF, "dma_read_ctrl done!");

LOAD_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_read_data_length) break;

            // DATA_WIDTH = 64
            // DATA_WIDTH = 32
            // discard bits in the DMA range(63,32)
            // keep bits in the DMA range(31,0)
            ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

            FPDATA_IN data;
            data.set_slc(0, data_ac);

            plm_in.data[i] = data;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }

        dma_read_data_index += dma_read_data_length;
    }

COMPUTE_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        ac_math::ac_softmax_pwl(plm_in.data, plm_out.data);
    }

STORE_OUTER_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA write channle (CTRL)
        dma_info_t dma_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());
        dma_write_ctrl.write(dma_info);
        ESP_REPORT_INFO(VOFF, "dma_read_ctrl done!");

STORE_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            if (i >= dma_write_data_length) break;

            FPDATA_OUT data = plm_out.data[i];

            // DMA_WIDTH = 64
            // DATA_WIDTH = 32
            // set to a constante value range(63,32)
            // return results on the range(31,0)
            ac_int<DMA_WIDTH, false> data_ac;
            ac_int<32, false> DEADBEEF = 0xdeadbeef;
            data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
            data_ac.set_slc(0, data.template slc<DATA_WIDTH>(0));

            dma_write_chnl.write(data_ac);

            ESP_REPORT_INFO(VOFF, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }

        dma_write_data_index += dma_write_data_length;
    }

    debug = 0;
}

#endif

