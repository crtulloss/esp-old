// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "dummy.hpp"
#include "dummy_directives.hpp"

// Functions

#include "dummy_functions.hpp"

// Processes

void dummy::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");
        this->reset_load_input();
        wait();
    }

    // Config
    uint32_t tokens;
    uint32_t batch;
    {
        HLS_PROTO("load-config");

        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        tokens = config.tokens;
        batch = config.batch;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load config(): tokens = %d, batch = %d", ESP_TO_UINT64(tokens), ESP_TO_UINT64(batch));
    }

    // Load
    bool ping = true;
    uint32_t offset = 0;

LOAD_INPUT_BATCH_LOOP:
    for (int n = 0; n < batch; n++)
    {

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): batch # %d start...", n+1);

LOAD_INPUT_TOKENS_LOOP:
        for (int b = tokens; b > 0; b -= PLM_SIZE)
        {
            HLS_PROTO("load-dma");

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): ping = %d", ping);

            uint32_t len = b > PLM_SIZE ? PLM_SIZE : b;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): len = %d [max %d]", ESP_TO_UINT64(len), PLM_SIZE);

            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
            offset += len;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_info.index = %d, dma_info.length = %d, dma_info.size = %d", ESP_TO_UINT64(dma_info.index), ESP_TO_UINT64(dma_info.length), dma_info.size.to_uint64());

#ifdef DMA_SINGLE_PROCESS
#if (__MNTR_CONNECTIONS__)
            this->dma_read_ctrl.PushNB(dma_info);
#else
            this->dma_read_ctrl.nb_write(dma_info);
#endif
#else
#if (__MNTR_CONNECTIONS__)
            this->dma_read_ctrl.Push(dma_info);
#else
            this->dma_read_ctrl.write(dma_info);
#endif
#endif

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_read_ctrl done!");

            plm_t plm_local;
LOAD_INPUT_DATA_LOOP:
            for (uint16_t i = 0; i < len; i++) {
                uint64_t data;
                sc_dt::sc_bv<64> data_bv;

#if (DMA_WIDTH == 64)
                ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_read_chnl...");

#if (__MNTR_CONNECTIONS__)
                data_bv = this->dma_read_chnl.Pop();
#else
                data_bv = this->dma_read_chnl.read();
#endif

                ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): dma_read_chnl done! (%lX)", data_bv.to_uint64());

#elif (DMA_WIDTH == 32)

#if (__MNTR_CONNECTIONS__)
                data_bv.range(31, 0) = this->dma_read_chnl.Pop();
#else
                data_bv.range(31, 0) = this->dma_read_chnl.read();
#endif
                wait();
#if (__MNTR_CONNECTIONS__)
                data_bv.range(63, 32) = this->dma_read_chnl.Pop();
#else
                data_bv.range(63, 32) = this->dma_read_chnl.read();
#endif
#endif
                wait();
                data = data_bv.to_uint64();

                plm_local.data[i] = data;
                if (ping) {
//                  plm0_local.data[i] = data;
                    ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): plm0[%d] := %X", i, data);
                } else {
//                  plm1_local.data[i] = data;
                    ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): plm1[%d] := %X", i, data);
                }
            }
            if (ping) {
                plm0.write(plm_local);
//              ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): plm0[%d] := %X", i, data);
            } else {
                plm1.write(plm_local);
//              ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): plm1[%d] := %X", i, data);
            }

            this->load_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load() --> compute()");

            ping = !ping;
        }
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Load load(): batch # %d done!", n+1);
    }

    // Conclude
    {
        this->process_done();
    }
}


void dummy::store_output()
{

    // Reset
    {
        HLS_PROTO("store-reset");
        this->reset_store_output();
        wait();
    }

    // Config
    uint32_t tokens;
    uint32_t batch;
    {
        HLS_PROTO("store-config");

        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        tokens = config.tokens;
        batch = config.batch;

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store config(): tokens = %d, batch = %d", ESP_TO_UINT64(tokens), ESP_TO_UINT64(batch));
    }

    // Store
    bool ping = true;
    uint32_t offset = 0;

STORE_OUTPUT_BATCH_LOOP:
    for (int n = 0; n < batch; n++)
    {

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): batch # %d start...", n+1);

STORE_OUTPUT_TOKENS_LOOP:
        for (int b = tokens; b > 0; b -= PLM_SIZE)
        {
            HLS_PROTO("store-dma");

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): ping = %d", ping);

            this->store_compute_handshake();
            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store() --> compute()");

            uint32_t len = b > PLM_SIZE ? PLM_SIZE : b;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): len = %d [max %d]", ESP_TO_UINT64(len), PLM_SIZE);

            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
            offset += len;

            ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): dma_info.index = %d, dma_info.length = %d, dma_info.size = %d", ESP_TO_UINT64(dma_info.index), ESP_TO_UINT64(dma_info.length), dma_info.size.to_uint64());

#ifdef DMA_SINGLE_PROCESS
#if (__MNTR_CONNECTIONS__)
            this->dma_write_ctrl.PushNB(dma_info);
#else
            this->dma_write_ctrl.nb_write(dma_info);
#endif
#else
#if (__MNTR_CONNECTIONS__)
            this->dma_write_ctrl.Push(dma_info);
#else
            this->dma_write_ctrl.write(dma_info);
#endif
#endif
            plm_t plm_local;
            if (ping) {
                plm_local = plm0.read();
            } else {
                plm_local = plm1.read();
            }

STORE_OUTPUT_DATA_LOOP:
            for (uint16_t i = 0; i < len; i++) {

                wait();
                uint64_t data = plm_local.data[i];
                if (ping) {
                    //data = plm0_local.data[i];
                    ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): plm0.data[%d] -> %X", i, data);
                } else {
                    //data = plm1.data[i];
                    ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): plm1[%d] -> %X", i, data);
                }
                sc_dt::sc_bv<64> data_bv(data);

#if (DMA_WIDTH == 64)

#if (__MNTR_CONNECTIONS__)
                this->dma_write_chnl.Push(data_bv);
#else
                this->dma_write_chnl.write(data_bv);
#endif

#elif (DMA_WIDTH == 32)

#if (__MNTR_CONNECTIONS__)
                this->dma_write_chnl.Push(data_bv.range(31, 0));
                wait();
                this->dma_write_chnl.Push(data_bv.range(64, 32));
#else
                this->dma_write_chnl.write(data_bv.range(31, 0));
                wait();
                this->dma_write_chnl.write(data_bv.range(64, 32));
#endif

#endif
            }
            ping = !ping;
        }

        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Store store(): batch # %d done!", n+1);
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void dummy::compute_kernel()
{

    // Reset
    {
        HLS_PROTO("compute-reset");
        this->reset_compute_kernel();
        wait();
    }

    // Config
    {
        HLS_PROTO("compute-config");
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();
    }


    // Compute (dummy does nothing)
COMPUTE_LOOP:
    while (true)
    {

        this->compute_load_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() ---> load()");
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute load() <---> store()");

        this->compute_store_handshake();
        ESP_REPORT_TIME(VOFF, sc_time_stamp(), "Compute compute() ---> store()");
    }
}


inline void dummy::reset_dma_read()
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

inline void dummy::reset_dma_write()
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

inline void dummy::reset_accelerator_done()
{
    acc_done.write(false);
}

// Utility functions

//#pragma design modulario
inline void dummy::process_done()
{
    //HLS_DEFINE_PROTOCOL("process-done");
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

//#pragma design modulario
inline void dummy::accelerator_done()
{
    //HLS_DEFINE_PROTOCOL("accelerator-done");
    acc_done.write(true); wait();
    acc_done.write(false);
}

inline void dummy::reset_load_input()
{
#if defined(__MNTR_CONNECTIONS__)
    input_ready.reset_req();
#else
    input_ready.req.reset_req();
#endif
    this->reset_dma_read();
}

inline void dummy::reset_compute_kernel()
{
#if defined(__MNTR_CONNECTIONS__)
    input_ready.reset_ack();
    output_ready.reset_req();
#else
    input_ready.ack.reset_ack();
    output_ready.req.reset_req();
#endif
}

inline void dummy::reset_store_output()
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
inline void dummy::load_compute_handshake()
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
inline void dummy::compute_load_handshake()
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
inline void dummy::compute_store_handshake()
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
inline void dummy::store_compute_handshake()
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


// Process
//#pragma design modulario
void dummy::config_accelerator()
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

// Function

inline void dummy::wait_for_config()
{
#pragma hls_unroll no
WAIT_FOR_CONFIG_LOOP:
    while (!done.read()) { wait(); }
}
