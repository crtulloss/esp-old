// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "softmax.hpp"

#include <ac_math/ac_softmax_pwl.h>

//
// Compute functions
//

template <class T1, unsigned S1, class T2, unsigned S2>
void compute(unsigned len, plm_t<T1,S1> *input, plm_t<T2,S2> *output) {
    ac_math::ac_softmax_pwl(input->data, output->data);
}

//
// Processes
//
#pragma design modulario<sync>
void softmax::config_accelerator() {
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

void softmax::load_input() {

    // Load-process reset
    {
        this->reset_load_input();
        wait();
    }

    // Load-process config
    uint32_t size;
    uint32_t batch;
    uint32_t in_offset;
    uint32_t out_offset;
    {
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        size = config.size;
        batch = config.batch;
        in_offset = config.in_offset;
        out_offset = config.out_offset;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load config(): size = %u, batch = %u, in_offset = %u, out_offset = %u", ESP_TO_UINT32(size), ESP_TO_UINT32(batch), ESP_TO_UINT32(in_offset), ESP_TO_UINT32(out_offset));
    }

    uint32_t offset = in_offset;

    bool ping = true;

    // Load-process body
LOAD_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {
LOAD_DATA_OUTER_LOOP:
        for (uint32_t s = size; s > 0; s -= PLM_SIZE) {

            uint32_t len = (s > (uint32_t)PLM_SIZE) ? (uint32_t)PLM_SIZE : s;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): len = %u [max %d]", ESP_TO_UINT32(len), PLM_SIZE);

            dma_info_t dma_info(offset, len, 32);

            offset += len;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_info.index = %u, dma_info.length = %u, dma_info.size = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());

            DMA_WRITE(dma_info, this->dma_read_ctrl);

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_read_ctrl done!");

            plm_t<FPDATA_IN, PLM_SIZE> plm_local;

LOAD_DATA_INNER_LOOP:
//#pragma hls_pipeline_init_interval 1
            for (uint16_t i = 0; i < len; i++) {
                FPDATA_IN data;
                sc_dt::sc_bv<32> data_bv;
                ac_int<32> data_ac;

                DMA_READ(data_bv, this->dma_read_chnl);

                data_ac = ac_int<32>(data_bv.to_uint());
                data.set_slc(0, data_ac);
                plm_local.data[i] = data;
            }

            if (ping) {
                plm0_in.write(plm_local);
            } else {
                plm1_in.write(plm_local);
            }

            this->load_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load() --> compute()");

            ping = !ping;
        }
    }

    // Load-process done
    {
        this->process_done();
    }
}

void softmax::compute_kernel() {

    // Compute-process reset
    {
        this->reset_compute_kernel();
        wait();
    }

    // Compute-process config
    uint32_t size;
    uint32_t batch;
    uint32_t in_offset;
    uint32_t out_offset;
    {
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        size = config.size;
        batch = config.batch;
        in_offset = config.in_offset;
        out_offset = config.out_offset;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute config(): size = %u, batch = %u, in_offset = %u, out_offset = %u", ESP_TO_UINT32(size), ESP_TO_UINT32(batch), ESP_TO_UINT32(in_offset), ESP_TO_UINT32(out_offset));
    }

    bool ping = true;

    // Compute-process body
COMPUTE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {

COMPUTE_OUTER_LOOP:
//#pragma hls_pipeline_init_interval 1
        for (uint32_t s = size; s > 0; s -= PLM_SIZE) {

            this->compute_load_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() <---> load()");

            uint32_t len = (s > (uint32_t)PLM_SIZE) ? (uint32_t)PLM_SIZE : s;

            plm_t<FPDATA_IN, PLM_SIZE> plm_local_in;
            plm_t<FPDATA_OUT, PLM_SIZE> plm_local_out;

            if (ping) {
                plm_local_in = plm0_in.read();
            } else {
                plm_local_in = plm1_in.read();
            }

            compute<FPDATA_IN, PLM_SIZE, FPDATA_OUT, PLM_SIZE>(len, &plm_local_in, &plm_local_out);

            if (ping) {
                plm0_out.write(plm_local_out);
            } else {
                plm1_out.write(plm_local_out);
            }

            this->compute_store_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() ---> store()");

            ping = !ping;
        }
    }

    // Compute-process done
    {
        this->process_done();
    }
}

void softmax::store_output() {

    // Store-process reset
    {
        this->reset_store_output();
        wait();
    }

    // Store-process config
    uint32_t size;
    uint32_t batch;
    uint32_t in_offset;
    uint32_t out_offset;
    {
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        size = config.size;
        batch = config.batch;
        in_offset = config.in_offset;
        out_offset = config.out_offset;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store config(): size = %u, batch = %u, in_offset = %u, out_offset = %u", ESP_TO_UINT32(size), ESP_TO_UINT32(batch), ESP_TO_UINT32(in_offset), ESP_TO_UINT32(out_offset));
    }

    uint32_t offset = out_offset;

    bool ping = true;

    // Store-process body
COMPUTE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {
STORE_MAIN_LOOP:
        for (uint32_t s = size; s > 0; s -= PLM_SIZE) {

            this->store_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store() --> compute()");

            uint32_t len = (s > (uint32_t)PLM_SIZE) ? (uint32_t)PLM_SIZE : s;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): len = %u [max %d]", ESP_TO_UINT32(len), PLM_SIZE);

            dma_info_t dma_info(offset, len, 32);

            offset += len;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): dma_info.index = %u, dma_info.length = %u, dma_info.size = %llu", ESP_TO_UINT32(dma_info.index), ESP_TO_UINT32(dma_info.length), dma_info.size.to_uint64());

            DMA_WRITE(dma_info, this->dma_write_ctrl);

            plm_t<FPDATA_OUT, PLM_SIZE> plm_local;

            if (ping) {
                plm_local = plm0_out.read();
            } else {
                plm_local = plm1_out.read();
            }

STORE_OUTPUT_INNER_LOOP:
//#pragma hls_pipeline_init_interval 1
            for (uint16_t i = 0; i < len; i++) {

                FPDATA_OUT data = plm_local.data[i];
                sc_dt::sc_bv<32> data_bv(data.template slc<32>(0));

                DMA_WRITE(data_bv, this->dma_write_chnl);
            }

            ping = !ping;
        }
    }

    // Store-process done
    {
        this->accelerator_done();
        this->process_done();
    }
}

// ***************************************************
// *** YOU SHOULD NOT EDIT THE FOLLOWING FUNCTIONS ***
// ***************************************************

//
// Reset functions
//

inline void softmax::reset_dma_read() {
    DMA_WRITE_RESET(dma_read_ctrl);
    DMA_READ_RESET(dma_read_chnl);
}

inline void softmax::reset_dma_write() {
    DMA_WRITE_RESET(dma_write_ctrl);
    DMA_WRITE_RESET(dma_write_chnl);
}

inline void softmax::reset_accelerator_done() {
    acc_done.write(false);
}

//
// Functions
//

inline void softmax::reset_load_input() {
    input_ready.reset_req();
    this->reset_dma_read();
}

inline void softmax::reset_compute_kernel() {
    input_ready.reset_ack();
    output_ready.reset_req();
}

inline void softmax::reset_store_output()
{
    output_ready.reset_ack();
    this->reset_accelerator_done();
    this->reset_dma_write();
}

inline void softmax::load_compute_handshake() {
    input_ready.req();
}

inline void softmax::compute_load_handshake() {
    input_ready.ack();
}

inline void softmax::compute_store_handshake() {
    output_ready.req();
}

inline void softmax::store_compute_handshake()
{
    output_ready.ack();
}

inline void softmax::wait_for_config() {
#pragma hls_unroll no
WAIT_FOR_CONFIG_LOOP:
    while (!done.read()) { wait(); }
}

inline void softmax::process_done() {
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

inline void softmax::accelerator_done() {
    acc_done.write(true); wait();
    acc_done.write(false);
}
