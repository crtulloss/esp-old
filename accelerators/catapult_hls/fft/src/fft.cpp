// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "fft.hpp"
#include "fft_directives.hpp"

// Functions

#include "fft_functions.hpp"

// Processes

void fft::load_input()
{

    // Reset
    {
        this->reset_load_input();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t len;
    int32_t log_len;
    {
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        log_len = config.log_len;
        len = 1 << log_len;

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load config(): log_len = %lld, len = %lld", ESP_TO_INT64(log_len), ESP_TO_INT64(len));
    }

    // Load
    {
        uint32_t offset = 0;

#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = 2 * len;
#else
        uint32_t length = round_up(2 * len, DMA_WORD_PER_BEAT);
#endif

        // Configure DMA transaction
#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, length * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
        dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, length / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
        offset += length;

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): dma_info.index = %llu, dma_info.length = %llu, dma_info.size = %llu", ESP_TO_UINT64(dma_info.index), ESP_TO_UINT64(dma_info.length), dma_info.size.to_uint64());

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

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): dma_read_ctrl done!");

        // Local PLM for the load process.

        plm_t plm_local;

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): local PLM size %u", PLM_IN_WORD);

#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        for (uint16_t i = 0; i < length; i++)
        {
            sc_dt::sc_bv<DATA_WIDTH> dataBv;

            for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
            {
                ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): dma_read_chnl...");

#if (__MNTR_CONNECTIONS__)
                dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.Pop();
#else
                dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.read();
#endif

                ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): dma_read_chnl done! (%016llX)", data_bv.to_uint64());
            }

            // Write to PLM
            plm_local.data[i] = dataBv.to_int64();

            ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): plm_local.data[%d] := %llX", i, dataBv.to_int64());
        }
#else
        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): dma_read_chnl...");

#if (__MNTR_CONNECTIONS__)
            dataBv = this->dma_read_chnl.Pop();
#else
            dataBv = this->dma_read_chnl.read();
#endif

            // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
            std::cout << DMA_WORD_PER_BEAT << std::endl;
#pragma hls_unroll yes
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                plm_local.data[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

                //ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load(): plm_local.data[%llu] := %llX", i+k, dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64());
            }

            ESP_REPORT_TIME(VON, sc_time_stamp(), "Loat load(): dma_read_chnl done! (%016llX)", dataBv.to_uint64());

        }
#endif
        plm_in.write(plm_local);

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load() --> compute(): pending...");

        this->load_compute_handshake();

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Load load() --> compute(): done!");
    }

    // Conclude
    {
        this->process_done();
    }
}


void fft::store_output()
{

    // Reset
    {
        this->reset_store_output();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t len;
    int32_t log_len;
    {
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        log_len = config.log_len;
        len = 1 << log_len;

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Store config(): log_len = %lld, len = %lld", ESP_TO_INT64(log_len), ESP_TO_INT64(len));
    }

    // Store
    {
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (2 * len) * 1;
#else
        uint32_t store_offset = round_up(2 * len, DMA_WORD_PER_BEAT) * 1;
#endif
        uint32_t offset = 0;

#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = 2 * len;
#else
        uint32_t length = round_up(2 * len, DMA_WORD_PER_BEAT);
#endif

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Store store() --> compute(): pending...");

        this->store_compute_handshake();

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Store store() --> compute(): done!");

        // Configure DMA transaction
#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, length * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
        dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, length / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
        offset += length;

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Stoare store(): dma_info.index = %llu, dma_info.length = %llu, dma_info.size = %llu", ESP_TO_UINT64(dma_info.index), ESP_TO_UINT64(dma_info.length), dma_info.size.to_uint64());

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

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Stoare store(): dma_write_ctrl done!");

        plm_t plm_local = plm_out.read();

#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        for (uint16_t i = 0; i < length; i++)
        {
            // Read from PLM
            sc_dt::sc_int<DATA_WIDTH> data;

            data = plm_local.data[i];
            sc_dt::sc_bv<DATA_WIDTH> dataBv(data);

            uint16_t k = 0;
            for (k = 0; k < DMA_BEAT_PER_WORD - 1; k++)
            {
                ESP_REPORT_TIME(VON, sc_time_stamp(), "Store store(): dma_write_chnl...");

#if (__MNTR_CONNECTIONS__)
                this->dma_write_chnl.Push(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
#else
                this->dma_write_chnl.write(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
#endif

                ESP_REPORT_TIME(VON, sc_time_stamp(), "Store store(): dma_write_chnl done! (%016llX)", data_bv.to_uint64());

            }
            // Last beat on the bus does not require wait(), which is
            // placed before accessing the PLM
            this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
        }
#else
        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            ESP_REPORT_TIME(VON, sc_time_stamp(), "Store store(): dma_write_chnl...");

            // Read from PLM
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_local.data[i + k];
            }

            ESP_REPORT_TIME(VON, sc_time_stamp(), "Store store(): dma_write_chnl done! (%016llX)", dataBv.to_uint64());

#if (__MNTR_CONNECTIONS__)
            this->dma_write_chnl.Push(dataBv);
#else
            this->dma_write_chnl.write(dataBv);
#endif

        }
#endif
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}

void fft::compute_kernel()
{
    // Reset
    {
        this->reset_compute_kernel();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    bool do_peak;
    bool do_bitrev;
    int32_t len;
    int32_t log_len;
    {
        wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        log_len = config.log_len;
        len = 1 << log_len;

        ESP_REPORT_TIME(VON, sc_time_stamp(), "Compute config(): log_len = %lld, len = %lld", ESP_TO_INT64(log_len), ESP_TO_INT64(len));

#ifndef STRATUS_HLS
        sc_assert(log_len < LOG_LEN_MAX);
#endif

        do_peak = config.do_peak;
        do_bitrev = config.do_bitrev;
    }

    ESP_REPORT_TIME(VON, sc_time_stamp(), "Compute compute() <---> load(): pending...");

    this->compute_load_handshake();

    ESP_REPORT_TIME(VON, sc_time_stamp(), "Compute compute() <---> load(): done!");


    plm_t plm_local = plm_in.read();

    // Compute FFT single pass (FIXME: assume vector fits in the PLM)
    {
        uint32_t length = 2 * len;

        // Optional step: bit reverse
        if (do_bitrev)
            fft_bit_reverse(len, log_len, plm_local);

        // Computing phase implementation
        int m = 1;  // iterative FFT

    FFT_SINGLE_L1:
        for(unsigned s = 1; s <= log_len; s++) {

            m = 1 << s;
            CompNum wm(myCos(s), mySin(s));
            // printf("s: %d\n", s);
            // printf("wm.re: %.15g, wm.im: %.15g\n", wm.re, wm.im);

        FFT_SINGLE_L2:
            for(unsigned k = 0; k < len; k +=m) {

                CompNum w((FPDATA) 1, (FPDATA) 0);
                int md2 = m / 2;

            FFT_SINGLE_L3:
                for(int j = 0; j < md2; j++) {

                    int kj = k + j;
                    int kjm = k + j + md2;

                    CompNum akj, akjm;
                    CompNum bkj, bkjm;

                    akj.re = int2fp<FPDATA, WORD_SIZE>(plm_local.data[2 * kj]);
                    akj.im = int2fp<FPDATA, WORD_SIZE>(plm_local.data[2 * kj + 1]);
                    akjm.re = int2fp<FPDATA, WORD_SIZE>(plm_local.data[2 * kjm]);
                    akjm.im = int2fp<FPDATA, WORD_SIZE>(plm_local.data[2 * kjm + 1]);

                    CompNum t;
                    compMul(w, akjm, t);
                    CompNum u(akj.re, akj.im);
                    compAdd(u, t, bkj);
                    compSub(u, t, bkjm);
                    CompNum wwm;
                    wwm.re = w.re - (wm.im * w.im + wm.re * w.re);
                    wwm.im = w.im + (wm.im * w.re - wm.re * w.im);
                    w = wwm;

                    {
                        plm_local.data[2 * kj] = fp2int<FPDATA, WORD_SIZE>(bkj.re);
                        plm_local.data[2 * kj + 1] = fp2int<FPDATA, WORD_SIZE>(bkj.im);
                        plm_local.data[2 * kjm] = fp2int<FPDATA, WORD_SIZE>(bkjm.re);
                        plm_local.data[2 * kjm + 1] = fp2int<FPDATA, WORD_SIZE>(bkjm.im);
                        // cout << "DFT: plm_local.data " << kj << ": " << plm_local.data[kj].re.to_hex() << " " << plm_local.data[kj].im.to_hex() << endl;
                        // cout << "DFT: plm_local.data " << kjm << ": " << plm_local.data[kjm].re.to_hex() << " " << plm_local.data[kjm].im.to_hex() << endl;
                    }
                }
            }
        }

    }

    plm_out.write(plm_local);

    ESP_REPORT_TIME(VON, sc_time_stamp(), "Compute compute() ---> store(): pending...");

    this->compute_store_handshake();

    ESP_REPORT_TIME(VON, sc_time_stamp(), "Compute compute() ---> store(): done!");


    // Conclude
    {
        this->process_done();
    }
}


inline void fft::reset_dma_read()
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

inline void fft::reset_dma_write()
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

inline void fft::reset_accelerator_done()
{
    acc_done.write(false);
}

// Utility functions

//#pragma design modulario
inline void fft::process_done()
{
    //HLS_DEFINE_PROTOCOL("process-done");
#pragma hls_unroll no
PROCESS_DONE_LOOP:
    do { wait(); } while (true);
}

//#pragma design modulario
inline void fft::accelerator_done()
{
    //HLS_DEFINE_PROTOCOL("accelerator-done");
    acc_done.write(true); wait();
    acc_done.write(false);
}

inline void fft::reset_load_input()
{
#if defined(__MNTR_CONNECTIONS__)
    input_ready.reset_req();
#else
    input_ready.req.reset_req();
#endif
    this->reset_dma_read();
}

inline void fft::reset_compute_kernel()
{
#if defined(__MNTR_CONNECTIONS__)
    input_ready.reset_ack();
    output_ready.reset_req();
#else
    input_ready.ack.reset_ack();
    output_ready.req.reset_req();
#endif
}

inline void fft::reset_store_output()
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
inline void fft::load_compute_handshake()
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
inline void fft::compute_load_handshake()
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
inline void fft::compute_store_handshake()
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
inline void fft::store_compute_handshake()
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
void fft::config_accelerator()
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

inline void fft::wait_for_config()
{
#pragma hls_unroll no
WAIT_FOR_CONFIG_LOOP:
    while (!done.read()) { wait(); }
}
