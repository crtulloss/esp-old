// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "softmax_conf_info.hpp"
#include "softmax_debug_info.hpp"
#include "softmax.hpp"

const size_t SIZE = 128;
const size_t BATCH = 16;

const size_t MEM_SIZE = 2 * SIZE * BATCH;

#include "core/systems/esp_system.hpp"

#ifndef __CUSTOM_SIM__
#include <mc_scverify.h>
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // Accelerator instance
#ifdef __CUSTOM_SIM__
    softmax *acc;
#else
    CCS_DESIGN(softmax) acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
#ifndef __CUSTOM_SIM__
        , acc("softmax")
#endif
    {
#if defined(__MATCHLIB_CONNECTIONS__)
        ESP_REPORT_TIME(VON, sc_time_stamp(), "enable MatchLib Connections");
#else
        ESP_REPORT_TIME(VON, sc_time_stamp(), "enable Legacy P2P");
#endif
#if defined(__MNTR_AC_SHARED__)
        ESP_REPORT_TIME(VON, sc_time_stamp(), "enable ac_shared PLMs");
#else
        ESP_REPORT_TIME(VON, sc_time_stamp(), "enable ac_channel PLMs");
#endif


        // Binding the accelerator
#ifdef __CUSTOM_SIM__
        acc = new softmax("softmax");

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

    //
    // Processes
    //

    // Configure accelerator
    void config_proc();

    // Load internal memory
    void load_memory();

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Accelerator-specific data
    uint32_t *out;

    // Other Functions
};

#endif // __SYSTEM_HPP__
