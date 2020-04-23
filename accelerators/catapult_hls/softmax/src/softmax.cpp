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

void softmax::config_accelerator()
{
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

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load config(): size = %llu, batch = %llu, in_offset = %llu, out_offset = %llu", ESP_TO_UINT64(size), ESP_TO_UINT64(batch), ESP_TO_UINT64(in_offset), ESP_TO_UINT64(out_offset));
    }

    uint32_t offset = in_offset;

    // Load-process body
LOAD_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {
LOAD_DATA_OUTER_LOOP:
        for (uint32_t s = size; s > 0; s -= PLM_SIZE) {

            uint32_t len = s > uint32_t(PLM_SIZE) ? uint32_t(PLM_SIZE) : s;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): len = %llu [max %d]", ESP_TO_UINT64(len), PLM_SIZE);

            dma_info_t dma_info(offset, len, 32);

            offset += len;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_info.index = %llu, dma_info.length = %llu, dma_info.size = %llu", ESP_TO_UINT64(dma_info.index), ESP_TO_UINT64(dma_info.length), dma_info.size.to_uint64());

#if (__MNTR_CONNECTIONS__)
            this->dma_read_ctrl.Push(dma_info);
#else
            this->dma_read_ctrl.write(dma_info);
#endif

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_read_ctrl done!");

            plm_t<FPDATA_IN, PLM_SIZE> plm_local;

LOAD_DATA_INNER_LOOP:
#pragma hls_pipeline_init_interval 1
            for (uint16_t i = 0; i < len; i++) {
                FPDATA_IN data;
                sc_dt::sc_bv<32> data_bv;
                ac_int<32> data_ac;

#if (__MNTR_CONNECTIONS__)
                data_bv = this->dma_read_chnl.Pop();
#else
                data_bv = this->dma_read_chnl.read();
#endif
                data_ac = ac_int<32>(data_bv.to_uint());
                data.set_slc(0, data_ac);
                plm_local.data[i] = data;
            }
            plm_in.write(plm_local);

            this->load_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load() --> compute()");
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

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute config(): size = %llu, batch = %llu, in_offset = %llu, out_offset = %llu", ESP_TO_UINT64(size), ESP_TO_UINT64(batch), ESP_TO_UINT64(in_offset), ESP_TO_UINT64(out_offset));
    }

    // Compute-process body
COMPUTE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {

//#pragma hls_pipeline_init_interval 1
COMPUTE_OUTER_LOOP:
        for (uint32_t s = size; s > 0; s -= PLM_SIZE) {

            this->compute_load_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() <---> load()");
    
            uint32_t len = s > uint32_t(PLM_SIZE) ? uint32_t(PLM_SIZE) : s;
    
            plm_t<FPDATA_IN, PLM_SIZE> plm_local_in;
            plm_t<FPDATA_OUT, PLM_SIZE> plm_local_out;
    
            plm_local_in = plm_in.read();
    
            compute<FPDATA_IN, PLM_SIZE, FPDATA_OUT, PLM_SIZE>(len, &plm_local_in, &plm_local_out);
    
            plm_out.write(plm_local_out);
    
            this->compute_store_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() ---> store()");
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

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store config(): size = %llu, batch = %llu, in_offset = %llu, out_offset = %llu", ESP_TO_UINT64(size), ESP_TO_UINT64(batch), ESP_TO_UINT64(in_offset), ESP_TO_UINT64(out_offset));
    }

    uint32_t offset = out_offset;

    // Store-process body
COMPUTE_BATCH_LOOP:
    for (uint32_t b = 0; b < batch; b++) {
STORE_MAIN_LOOP:
        for (uint32_t s = size; s > 0; s -= PLM_SIZE) {
    
            this->store_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store() --> compute()");
    
            uint32_t len = s > uint32_t(PLM_SIZE) ? uint32_t(PLM_SIZE) : s;
    
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): len = %llu [max %d]", ESP_TO_UINT64(len), PLM_SIZE);
    
            dma_info_t dma_info(offset, len, 32);

            offset += len;
    
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): dma_info.index = %llu, dma_info.length = %llu, dma_info.size = %llu", ESP_TO_UINT64(dma_info.index), ESP_TO_UINT64(dma_info.length), dma_info.size.to_uint64());

#if (__MNTR_CONNECTIONS__)
            this->dma_write_ctrl.Push(dma_info);
#else
            this->dma_write_ctrl.write(dma_info);
#endif
 
            plm_t<FPDATA_OUT, PLM_SIZE> plm_local;
            plm_local = plm_out.read();

STORE_OUTPUT_INNER_LOOP:
#pragma hls_pipeline_init_interval 1
            for (uint16_t i = 0; i < len; i++) {

                FPDATA_OUT data = plm_local.data[i];
                //ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): plm_out.data[%d] -> %llX", i, data);
                sc_dt::sc_bv<32> data_bv(data.template slc<32>(0));

#if (__MNTR_CONNECTIONS__)
                this->dma_write_chnl.Push(data_bv);
#else
                this->dma_write_chnl.write(data_bv);
#endif
            }
        }
    }

    // Store-process done
    {
        this->accelerator_done();
        this->process_done();
    }
}

//
// Reset functions
//

inline void softmax::reset_dma_read()
{
#if defined(__MNTR_CONNECTIONS__)
    // Reset
    dma_read_ctrl.Reset();
    dma_read_chnl.Reset();
#else
    // Reset
    dma_read_ctrl.reset_write();
    dma_read_chnl.reset_read();
#endif
}

inline void softmax::reset_dma_write()
{
#if defined(__MNTR_CONNECTIONS__)
    // Reset
    dma_write_ctrl.Reset();
    dma_write_chnl.Reset();
#else
    // Reset
    dma_write_ctrl.reset_write();
    dma_write_chnl.reset_write();
#endif
}

inline void softmax::reset_accelerator_done()
{
    acc_done.write(false);
}

//
// Functions
//

inline void softmax::reset_load_input()
{
#if defined(__MNTR_CONNECTIONS__)
    input_ready.reset_req();
#else
    input_ready.req.reset_req();
#endif
    this->reset_dma_read();
}

inline void softmax::reset_compute_kernel()
{
#if defined(__MNTR_CONNECTIONS__)
    input_ready.reset_ack();
    output_ready.reset_req();
#else
    input_ready.ack.reset_ack();
    output_ready.req.reset_req();
#endif
}

inline void softmax::reset_store_output()
{
#if defined(__MNTR_CONNECTIONS__)
    output_ready.reset_ack();
#else
    output_ready.ack.reset_ack();
#endif
    this->reset_accelerator_done();
    this->reset_dma_write();
}

//#pragma design modulario
inline void softmax::load_compute_handshake()
{
    {
        //HLS_DEFINE_PROTOCOL("load-compute-handshake");
#if defined(__MNTR_CONNECTIONS__)
        input_ready.req();
#else
        input_ready.req.req();
#endif
    }
}

//#pragma design modulario
inline void softmax::compute_load_handshake()
{
    {
        //HLS_DEFINE_PROTOCOL("compute-load-handshake");
#if defined(__MNTR_CONNECTIONS__)
        input_ready.ack();
#else
        input_ready.ack.ack();
#endif
    }
}

//#pragma design modulario
inline void softmax::compute_store_handshake()
{
    {
        //HLS_DEFINE_PROTOCOL("compute-store-handshake");
#if defined(__MNTR_CONNECTIONS__)
        output_ready.req();
#else
        output_ready.req.req();
#endif
    }
}

//#pragma design modulario
inline void softmax::store_compute_handshake()
{
    {
        //HLS_DEFINE_PROTOCOL("store-compute-handshake");
#if defined(__MNTR_CONNECTIONS__)
        output_ready.ack();
#else
        output_ready.ack.ack();
#endif
    }
}

inline void softmax::wait_for_config()
{
#pragma hls_unroll no
WAIT_FOR_CONFIG_LOOP:
    while (!done.read()) { wait(); }
}

//#pragma design modulario
inline void softmax::process_done()
{
    //HLS_DEFINE_PROTOCOL("process-done");
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

//#pragma design modulario
inline void softmax::accelerator_done()
{
    //HLS_DEFINE_PROTOCOL("accelerator-done");
    acc_done.write(true); wait();
    acc_done.write(false);
}
