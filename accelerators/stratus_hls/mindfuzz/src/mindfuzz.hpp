// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MINDFUZZ_HPP__
#define __MINDFUZZ_HPP__

// put these first in order to define TYPE, which conf needs
#include "mindfuzz_directives.hpp"
#include "fpdata.hpp"

#include "mindfuzz_conf_info.hpp"
#include "mindfuzz_debug_info.hpp"

#include "esp_templates.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DATA_WIDTH 32
#define DMA_SIZE SIZE_HWORD
#define PLM_OUT_WORD 2432
#define PLM_IN_WORD 65536

#define NUM_BUFF_ELEMENTS 4

#define CONST_NUM_WINDOWS 32
#define CONST_WINDOW_SIZE 8
#define CONST_NEURONS_PERWIN 4

class mindfuzz : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(mindfuzz);
    mindfuzz(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Map arrays to memories
        // deleted output pingpong
        HLS_MAP_plm(plm_out, PLM_OUT_NAME);
        HLS_MAP_plm(plm_in_pong, PLM_IN_NAME);
        HLS_MAP_plm(plm_in_ping, PLM_IN_NAME);
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure mindfuzz
    esp_config_proc cfg;

    // Functions
    void relevant(int32_t total_tsamps,
                  int32_t num_windows,
                  int32_t window_size,
                  bool flag[],
                  bool ping,
                  TYPE thresh);
    void backprop(bool do_relu,
                  TYPE learning_rate,
                  int32_t tsamps_perbatch,
                  int32_t num_windows,
                  int32_t epochs_perbatch,
                  int32_t input_dimension,
                  int32_t layer1_dimension,
                  int32_t output_dimension,
                  int32_t W1_size,
                  int32_t W2_size,
                  int32_t B1_size,
                  int32_t B2_size,
                  int32_t batch,
                  bool flag[],
                  bool ping);

    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> plm_in_ping[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_in_pong[PLM_IN_WORD];
    // deleted output pingpong
    sc_dt::sc_int<DATA_WIDTH> plm_out[PLM_OUT_WORD];

    // for detection buffer coordination
    // TODO revisit this
    // sc_bv<4> full;

};


#endif /* __MINDFUZZ_HPP__ */
