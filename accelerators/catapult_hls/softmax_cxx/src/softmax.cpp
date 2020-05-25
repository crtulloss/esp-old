// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>
#include <mc_scverify.h>
#include <ac_wait.h>

#pragma hls_design
void config(
        conf_info_t &conf_info,
        bool conf_done,
        /*uint32_t &batch*/
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
        //uint32_t batch,
        ac_channel<conf_info_t> &plm_conf,
        ac_channel<plm_in_t> &plm_in,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<ac_int<DMA_WIDTH, false> > &dma_read_chnl) {

    conf_info_t conf_info_tmp = plm_conf.read();

    uint32_t batch = conf_info_tmp.batch;

    uint32_t offset = 0;

LOAD_OUTER_LOOP:
    for (uint32_t b = 0; b < BATCH_SIZE_MAX; b++) {

        if (b >= batch) break;

        dma_info_t dma_info = {offset, PLM_SIZE, PLM_SIZE};

        offset += PLM_SIZE;

        ESP_REPORT_INFO(VON, "DMA offset = %u, DMA transfer size = %u, DMA width = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());

        dma_read_ctrl.write(dma_info);

        ESP_REPORT_INFO(VON, "dma_read_ctrl done!");

        plm_t<FPDATA_IN, PLM_SIZE> plm_tmp;

LOAD_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {

            // DMA_WIDTH = 64
            // discard bits in the range(63,32)
            // keep bits in the range(31,0)
            ac_int<32, false> data_ac = dma_read_chnl.read().template slc<32>(0);

            FPDATA_IN data;
            data.set_slc(0, data_ac);

            plm_tmp.data[i] = data;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }

        plm_in.write(plm_tmp);

        ESP_REPORT_INFO(VON, "load() --> compute()");
    }
}

#pragma hls_design
void compute(
        //uint32_t batch,
        ac_channel<conf_info_t> &plm_conf,
        ac_channel<plm_in_t> &plm_in,
        ac_channel<plm_out_t> &plm_out) {

    conf_info_t conf_info_tmp = plm_conf.read();

    uint32_t batch = conf_info_tmp.batch;

COMPUTE_LOOP:
    for (uint32_t b = 0; b < BATCH_SIZE_MAX; b++) {

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
        //uint32_t batch,
        ac_channel<conf_info_t> &plm_conf,
        ac_channel<plm_out_t> &plm_out,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<ac_int<DMA_WIDTH, false> > &dma_write_chnl) {

    conf_info_t conf_info_tmp = plm_conf.read();

    uint32_t batch = conf_info_tmp.batch;

    uint32_t offset = 0;

STORE_OUTER_LOOP:
    for (uint32_t b = 0; b < BATCH_SIZE_MAX; b++) {

        if (b >= batch) break;

        ESP_REPORT_INFO(VON, "store() --> compute()");

        dma_info_t dma_info = {offset, PLM_SIZE, PLM_SIZE};

        offset += PLM_SIZE;

        ESP_REPORT_INFO(VON, "DMA offset = %u, DMA transfer size = %u, DMA width = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());

        dma_write_ctrl.write(dma_info);

        ESP_REPORT_INFO(VON, "dma_read_ctrl done!");

        plm_t<FPDATA_OUT, PLM_SIZE> plm_tmp = plm_out.read();

STORE_INNER_LOOP:
        for (uint16_t i = 0; i < PLM_SIZE; i++) {
            FPDATA_OUT data = plm_tmp.data[i];

            // DMA_WIDTH = 64
            // set to a constante value range(63,32)
            // return results on the range(31,0)
            ac_int<64, false> data_ac;
            ac_int<32, false> DEADBEEF = 0xdeadbeef;
            data_ac.set_slc(32, DEADBEEF.template slc<32>(0));
            data_ac.set_slc(0, data.template slc<32>(0));

            dma_write_chnl.write(data_ac);

            ESP_REPORT_INFO(VOFF, "plm_out[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }
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
        ac_channel<ac_int<DMA_WIDTH, false> > &dma_read_chnl,
        ac_channel<ac_int<DMA_WIDTH, false> > &dma_write_chnl) {

    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(conf_info.batch));

    static ac_channel<plm_in_t> plm_in;
    static ac_channel<plm_out_t> plm_out;
    //static uint32_t batch;
    static ac_channel<conf_info_t> plm_conf_load;
    static ac_channel<conf_info_t> plm_conf_compute;
    static ac_channel<conf_info_t> plm_conf_store;

    config(conf_info, conf_done, /*batch*/ plm_conf_load, plm_conf_compute, plm_conf_store);

    load(/*batch,*/ plm_conf_load, plm_in, dma_read_ctrl, dma_read_chnl);
    compute(/*batch,*/ plm_conf_compute, plm_in, plm_out);
    store(/*batch,*/ plm_conf_store, plm_out, dma_write_ctrl, dma_write_chnl);

    debug = 0;
}


