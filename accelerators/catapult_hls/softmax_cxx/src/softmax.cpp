// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>
#include <mc_scverify.h>

#ifdef HIERARCHICAL_BLOCKS

#pragma hls_design
void config(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<conf_info_t> &plm_conf_load,
        ac_channel<conf_info_t> &plm_conf_compute,
        ac_channel<conf_info_t> &plm_conf_store,
        ac_sync &done) {

    uint32_t batch = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    batch = conf_info.read().batch;

    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(batch));

    conf_info_t conf_info_load_tmp;
    conf_info_t conf_info_compute_tmp;
    conf_info_t conf_info_store_tmp;

    conf_info_load_tmp.batch = batch;
    conf_info_compute_tmp.batch = batch;
    conf_info_store_tmp.batch = batch;

    plm_conf_load.write(conf_info_load_tmp);
    plm_conf_compute.write(conf_info_compute_tmp);
    plm_conf_store.write(conf_info_store_tmp);

    done.sync_out();
}

#pragma hls_design
void load(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<plm_in_t> &plm_in,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_sync &done) {

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;

    uint32_t batch = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    batch = conf_info.read().batch;

LOAD_BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_info_t dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        // Required to create shared memories
        plm_t<FPDATA_IN, PLM_SIZE> plm_tmp;

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_read_data_length) break;

                // DATA_WIDTH = 64
                // DATA_WIDTH = 32
                // discard bits in the DMA range(63,32)
                // keep bits in the DMA range(31,0)
#ifndef __SYNTHESIS__
                while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                ac_int<DATA_WIDTH, false> data_ac = dma_read_chnl.read().template slc<DATA_WIDTH>(0);

                FPDATA_IN data;
                data.set_slc(0, data_ac);

                plm_tmp.data[i] = data;

                ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
            }
        }

        plm_in.write(plm_tmp);

        ESP_REPORT_INFO(VON, "load() --> compute()");
    }

    done.sync_out();
}

#pragma hls_design
void compute(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<plm_in_t> &plm_in,
        ac_channel<plm_out_t> &plm_out,
        ac_sync &done) {

    uint32_t batch = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    batch = conf_info.read().batch;

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

    done.sync_out();
}

#pragma hls_design
void store(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<plm_out_t> &plm_out,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &done) {

    // Bookkeping variables
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;

    uint32_t batch = 0;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    batch = conf_info.read().batch;

STORE_BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        ESP_REPORT_INFO(VON, "store() --> compute()");

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_write_data_length * batch) + dma_write_data_length * b;
        dma_info_t dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
        do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
            // Required to create shared memories
            plm_t<FPDATA_OUT, PLM_SIZE> plm_tmp = plm_out.read();

STORE_INNER_LOOP:
            for (uint16_t i = 0; i < PLM_SIZE; i++) {

                if (i >= dma_write_data_length) break;

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
        }
    }

    done.sync_out();
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void softmax_cxx(
#else
void CCS_BLOCK(softmax_cxx)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    static ac_channel<plm_in_t> plm_in;
    static ac_channel<plm_out_t> plm_out;

    static ac_channel<conf_info_t> plm_conf_load;
    static ac_channel<conf_info_t> plm_conf_compute;
    static ac_channel<conf_info_t> plm_conf_store;
    static ac_sync config_done;
    static ac_sync load_done;
    static ac_sync compute_done;
    static ac_sync store_done;

    config(conf_info, plm_conf_load, plm_conf_compute, plm_conf_store, config_done);

    load(plm_conf_load, plm_in, dma_read_ctrl, dma_read_chnl, load_done);
    compute(plm_conf_compute, plm_in, plm_out, compute_done);
    store(plm_conf_store, plm_out, dma_write_ctrl, dma_write_chnl, store_done);

    config_done.sync_in();
    load_done.sync_in();
    compute_done.sync_in();
    store_done.sync_in();

    acc_done.sync_out();
}

#else

template <class T1, class T2>
void compute_wrapper(T1 &input, T2 &output) {
    ac_math::ac_softmax_pwl(input.data, output.data);
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void softmax_cxx(
#else
void CCS_BLOCK(softmax_cxx)(
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

    // Private Local Memories
    plm_in_t plm_in;
    plm_out_t plm_out;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif
    batch = conf_info.read().batch;

    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(batch));

BATCH_LOOP:
    for (uint32_t b = 0; b < BATCH_MAX; b++) {

        if (b >= batch) break;

        // Configure DMA read channel (CTRL)
        dma_read_data_index = dma_read_data_length * b;
        dma_read_info = {dma_read_data_index, dma_read_data_length, DMA_SIZE};
        bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

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

                FPDATA_IN data;
                data.set_slc(0, data_ac);

                plm_in.data[i] = data;

                ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
            }
        }

        compute_wrapper<plm_in_t, plm_out_t>(plm_in, plm_out);

        // Configure DMA write channle (CTRL)
        dma_write_data_index = (dma_write_data_length * batch) + dma_write_data_length * b;
        dma_write_info = {dma_write_data_index, dma_write_data_length, DMA_SIZE};
        bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
        do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [2 = 32b, 3 = 64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
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
    }

    acc_done.sync_out();
}

#endif

