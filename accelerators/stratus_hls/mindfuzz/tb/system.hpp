// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "mindfuzz.hpp"
#include "mindfuzz_directives.hpp"

#include "esp_templates.hpp"

// determine mem size in bytes
#if (FX_WIDTH == 16)
// float still takes 4 bytes
const size_t MEM_SIZE = 1284864 / (DMA_WIDTH/8);
#else // 32
const size_t MEM_SIZE = 2569728 / (DMA_WIDTH/8);
#endif // 16 vs 32

// old 
//const size_t MEM_SIZE = 139198464 / (DMA_WIDTH/8);

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "mindfuzz_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    mindfuzz_wrapper *acc;
#else
    mindfuzz *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
    {
        // ACC
#ifdef CADENCE
        acc = new mindfuzz_wrapper("mindfuzz_wrapper");
#else
        acc = new mindfuzz("mindfuzz_wrapper");
#endif
        // Binding ACC
        acc->clk(clk);
        acc->rst(acc_rst);
        acc->dma_read_ctrl(dma_read_ctrl);
        acc->dma_write_ctrl(dma_write_ctrl);
        acc->dma_read_chnl(dma_read_chnl);
        acc->dma_write_chnl(dma_write_chnl);
        acc->conf_info(conf_info);
        acc->conf_done(conf_done);
        acc->acc_done(acc_done);
        acc->debug(debug);

        /* <<--params-default-->> */
        window_size = 32;
        batches_perload = 1;
        hiddens_perwin = 6;
        tsamps_perbatch = 90;
// edited for mindfuzz unit testing
        num_windows = 1;
        iters_perbatch = 1;
        num_loads = 222;
#ifdef split_LR
        // version with split learning rate.
        // learning_rate * shift_A * shift_down_C = non-split learning rate
#if (FX_WIDTH == 16)
        learning_rate = TYPE(((float)numerator_B) / ((float)225));
#else // 32
        learning_rate = TYPE(((float)numerator_B) / ((float)703125));
#endif // 16 vs 32

#else
        // version with single learning rate.
        // note that calculus factor of 2 has been manually applied here
        learning_rate = TYPE(((float)0.000002) / ((float)tsamps_perbatch) / ((float)window_size));
#endif
// for testing with fixed point. this ^ learning rate won't fit in precision
        //learning_rate = TYPE(((float)0.001) / ((float)tsamps_perbatch) / ((float)window_size));
        rate_mean = TYPE(0.01);
        rate_variance = TYPE(0.01);
        do_init = true;
        do_backprop = true;
        do_thresh_update = true;
    }

    // Processes

    // Configure accelerator
    void config_proc();

    // Load internal memory
    void load_memory();

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Accelerator-specific data
    /* <<--params-->> */
    int32_t window_size;
    int32_t batches_perload;
    TYPE learning_rate;
    int32_t hiddens_perwin;
    int32_t tsamps_perbatch;
    int32_t num_windows;
    int32_t iters_perbatch;
    int32_t num_loads;
    TYPE rate_mean;
    TYPE rate_variance;
    bool do_init;
    bool do_backprop;
    bool do_thresh_update;

    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t out_size;
    float *in;
    float *out;
    float *gold;

    // Other Functions
};

#endif // __SYSTEM_HPP__
