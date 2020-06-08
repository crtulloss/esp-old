// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SOFTMAX_HPP__
#define __SOFTMAX_HPP__

#include "softmax_fpdata.hpp"
#include "softmax_conf_info.hpp"
#include "softmax_debug_info.hpp"

#include "utils/esp_utils.hpp"
#include "utils/esp_handshake.hpp"
#include "core/systems/esp_dma_info.hpp"

#include <ac_sync.h>

#include <ac_channel.h>
template <class T, unsigned S>
struct plm_t {
public:
   T data[S];
};

// NoC-/Accelerator-interface dimensions
#define DMA_WIDTH 64
#define DMA_SIZE SIZE_DWORD

typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define DATA_WIDTH 32
#define PLM_SIZE 128

#define BATCH_MAX 16

// PLM typedefs
typedef plm_t<FPDATA_IN, PLM_SIZE> plm_in_t;
typedef plm_t<FPDATA_OUT, PLM_SIZE> plm_out_t;

SC_MODULE(softmax_sysc) {
public:

    //
    // Input ports
    //

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Accelerator configuration
    sc_in<conf_info_t> conf_info;

    // Accelerator start signal
    sc_in<bool> conf_done;

    //
    // Output ports
    //

    // Computation complete
    sc_out<bool> acc_done;

    // Debug port
    sc_out<debug_info_t> debug;

    //
    // Data-transfer channels
    //

    // DMA read control
    Connections::Out<dma_info_t> dma_read_ctrl;

    // DMA write control
    Connections::Out<dma_info_t> dma_write_ctrl;

    // DMA read channel
    Connections::In<dma_data_t> dma_read_chnl;

    // DMA write channel
    Connections::Out<dma_data_t> dma_write_chnl;

    //
    // Process handshake
    //

    // Process synchronization
    sc_signal<bool> done;

    // Input <-> Computation
    handshake_t input_ready;

    // Computation <-> Output
    handshake_t output_ready;

    // Constructor
    SC_HAS_PROCESS(softmax_sysc);
    softmax_sysc(const sc_module_name& name)
        : sc_module(name)
          , clk("clk")
          , rst("rst")
          , conf_info("conf_info")
          , conf_done("conf_done")
          , acc_done("acc_done")
          , debug("debug")
          , dma_read_ctrl("dma_read_ctrl")
          , dma_write_ctrl("dma_write_ctrl")
          , dma_read_chnl("dma_read_chnl")
          , dma_write_chnl("dma_write_chnl")
          , done("done")
          , input_ready("input_ready")
          , output_ready("output_ready")
    {
#if 0
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
#else
        SC_CTHREAD(run, clk.pos());
        reset_signal_is(rst, false);
        // set_stack_size(0x400000);
#endif
    }

    //
    // Processes
    //
#if 0
    // Configure the accelerator
    void config();
    // Load the input data
    void load();
    // Computation
    void compute();
    // Store the output data
    void store();
#else
    // Single process config/loag/compute/store
    void run();
#endif
    //
    // Reset functions
    //

    // Reset DMA read channels
    inline void reset_dma_read();
    // Reset DMA write channels
    inline void reset_dma_write();
    // Reset the accelerator status
    inline void reset_accelerator_done();

    //
    // Functions
    //

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
    // The process is done
    inline void process_done();
    // The accelerator is done
    inline void accelerator_done();

    //
    // Private local memories
    //
    ac_channel<plm_in_t> plm_in;
    ac_channel<plm_out_t> plm_out;
};

#endif /* __SOFTMAX_HPP__ */
