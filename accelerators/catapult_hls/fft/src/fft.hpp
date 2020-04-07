// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __FFT_HPP__
#define __FFT_HPP__

#include "fpdata.hpp"
#include "fft_conf_info.hpp"
#include "fft_debug_info.hpp"

#include "fft_directives.hpp"

#include "utils/esp_utils.hpp"
#include "core/systems/esp_dma_info.hpp"
#include "utils/esp_handshake.hpp"

#include <ac_channel.h>

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define LOG_LEN_MAX 4
#define LEN_MAX (1 << LOG_LEN_MAX)
#define DATA_WIDTH FX_WIDTH
#if (FX_WIDTH == 64)
#define DMA_SIZE SIZE_DWORD
#elif (FX_WIDTH == 32)
#define DMA_SIZE SIZE_WORD
#endif // FX_WIDTH
#define PLM_IN_WORD (LEN_MAX << 1)

typedef struct {
    ac_int<DATA_WIDTH> data[PLM_IN_WORD];
} plm_t;

SC_MODULE(fft) {
public:
    // Input ports

    // Clock signal
    sc_in<bool> clk;
    // Reset signal
    sc_in<bool> rst;

#if defined(__MNTR_CONNECTIONS__)
    // DMA read channel
    Connections::In<sc_dt::sc_bv<DMA_WIDTH> > dma_read_chnl;
#else
    // DMA read channel (blocking)
    p2p<>::in<sc_dt::sc_bv<DMA_WIDTH> > dma_read_chnl;
#endif

    // Accelerator configuration
    sc_in<conf_info_t> conf_info;

    // Accelerator start signal
    sc_in<bool> conf_done;

    // Output ports

    // Computation complete
    sc_out<bool> acc_done;

    // Debug port
    sc_out<debug_info_t> debug;

#if defined(__MNTR_CONNECTIONS__)
    // DMA read control (non blocking)
    Connections::Out<dma_info_t> dma_read_ctrl;
    // DMA write control (non blocking)
    Connections::Out<dma_info_t> dma_write_ctrl;
    // DMA write channel (blocking)
    Connections::Out<sc_dt::sc_bv<DMA_WIDTH> > dma_write_chnl;
#else
    // DMA read control
    p2p<>::out<dma_info_t> dma_read_ctrl;

    // DMA write control
    p2p<>::out<dma_info_t> dma_write_ctrl;

    // DMA write channel
    p2p<>::out<sc_dt::sc_bv<DMA_WIDTH> > dma_write_chnl;
#endif

    // Handshakes

    // Input <-> Computation
    handshake_t input_ready;
    // Computation <-> Output
    handshake_t output_ready;

    // Process synchronization
    sc_signal<bool> done;

    // Constructor
    SC_HAS_PROCESS(fft);
    fft(const sc_module_name& name)
        : sc_module(name)
          , clk("clk")
          , rst("rst")
          , dma_read_chnl("dma_read_chnl")
          , conf_info("conf_info")
          , conf_done("conf_done")
          , acc_done("acc_done")
          , debug("debug")
          , dma_read_ctrl("dma_read_ctrl")
          , dma_write_ctrl("dma_write_ctrl")
          , dma_write_chnl("dma_write_chnl")
          , input_ready("input_ready")
          , output_ready("output_ready")
          , done("done")
    {
        // Signal binding

        SC_CTHREAD(config_accelerator, clk.pos());
        reset_signal_is(rst, false);
        // set_stack_size(0x400000);

        SC_CTHREAD(load_input, this->clk.pos());
        this->reset_signal_is(this->rst, false);
        // set_stack_size(0x400000);

        SC_CTHREAD(compute_kernel, this->clk.pos());
        this->reset_signal_is(this->rst, false);
        // set_stack_size(0x400000);

        SC_CTHREAD(store_output, this->clk.pos());
        this->reset_signal_is(this->rst, false);
        // set_stack_size(0x400000);
    }

    // Reset functions

    // Reset DMA read channels
    inline void reset_dma_read();
    // Reset DMA write channels
    inline void reset_dma_write();
    // Reset the accelerator status
    inline void reset_accelerator_done();

    // Utility functions

    // The process is done
    inline void process_done();
    // The accelerator is done
    inline void accelerator_done();

    // Processes

    // Configure the accelerator
    void config_accelerator();
    // Load the input data
    void load_input();
    // Computation
    void compute_kernel();
    // Store the output data
    void store_output();

    // Functions

    // Reset callable by load_input
    inline void reset_load_input();
    // Reset callable by compute_kernel
    inline void reset_compute_kernel();
    // Reset callable by store_output
    inline void reset_store_output();
    // Handshake callable by load_input
    inline void load_compute_handshake();
    // Handshake callable by compute_kernel
    inline void compute_load_handshake();
    // Handshake callable by compute_kernel
    inline void compute_store_handshake();
    // Handshake callable by store_output
    inline void store_compute_handshake();
    // Call to wait for configuration
    inline void wait_for_config();

    void fft_bit_reverse(unsigned int n, unsigned int bits, plm_t &plm_local);

    // Private local memories
    ac_channel<plm_t> plm_in;
    ac_channel<plm_t> plm_out;
};

#endif /* __FFT_HPP__ */
