// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "dummy_conf_info.hpp"
#include "dummy_debug_info.hpp"
#include "dummy.hpp"
#include "dummy_directives.hpp"

//#include "esp_templates.hpp"

const size_t MEM_SIZE = 2048;

#include "core/systems/esp_system.hpp"

#ifndef __CUSTOM_SIM__
#include <mc_scverify.h>
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef __CUSTOM_SIM__
    dummy *acc;
#else
    CCS_DESIGN(dummy) acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
#ifndef __CUSTOM_SIM__
        , acc("dummy")
#endif        
    {

#ifdef __CUSTOM_SIM__
        acc = new dummy("dummy");

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
#else
        // Binding ACC
        acc.clk(clk);
        acc.rst(acc_rst);
        acc.dma_read_ctrl(dma_read_ctrl);
        acc.dma_write_ctrl(dma_write_ctrl);
        acc.dma_read_chnl(dma_read_chnl);
        acc.dma_write_chnl(dma_write_chnl);
        acc.conf_info(conf_info);
        acc.conf_done(conf_done);
        acc.acc_done(acc_done);
        acc.debug(debug);
#endif
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
    uint64_t *out;

    // Other Functions
};

#endif // __SYSTEM_HPP__
