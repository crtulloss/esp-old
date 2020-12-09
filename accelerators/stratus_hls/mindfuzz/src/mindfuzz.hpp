// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MINDFUZZ_HPP__
#define __MINDFUZZ_HPP__

// put these first in order to define TYPE, which conf needs
#include "mindfuzz_directives.hpp"
#include "fpdata.hpp"

// useful macros for accessing PLMs
// these are needed for conf info
#define a_write(x) (fp2int<TYPE, WORD_SIZE>(x))
#define a_read(x) (int2fp<TYPE, WORD_SIZE>(x))

#include "mindfuzz_conf_info.hpp"
#include "mindfuzz_debug_info.hpp"

#include "esp_templates.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DATA_WIDTH 32
#define DMA_SIZE SIZE_HWORD

//#define PLM_OUT_WORD 2432
//#define PLM_IN_WORD 65536

// TODO formalize these as the maximum sizes so they can be used for array sizing e.g. flag array
// macro versions of some config parameters, in case we don't want them configable
#define CONST_NUM_WINDOWS 1
#define CONST_WINDOW_SIZE 4
#define CONST_NEURONS_PERWIN 1
#define CONST_TSAMPS_PERBATCH 70
#define CONST_BATCHES_PERLOAD 1
//#define do_bias

// new sizes for one-window test
#define PLM_OUT_WORD CONST_NUM_WINDOWS*CONST_WINDOW_SIZE*CONST_NEURONS_PERWIN
#define PLM_IN_WORD CONST_NUM_WINDOWS*CONST_WINDOW_SIZE*CONST_TSAMPS_PERBATCH*CONST_BATCHES_PERLOAD
#define PLM_ELEC_WORD CONST_NUM_WINDOWS*CONST_WINDOW_SIZE


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

        // PLMs sized by number of electrodes
        // useful for relevancy detection
        HLS_MAP_plm(plm_maxmin, PLM_ELEC_NAME);
        HLS_MAP_plm(plm_mean_noise, PLM_ELEC_NAME);
        HLS_MAP_plm(plm_mean_spike, PLM_ELEC_NAME);
        HLS_MAP_plm(plm_thresh, PLM_ELEC_NAME);

        // flatten the flag array into registers
        HLS_FLATTEN_ARRAY(flag);
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
                  bool ping);

    void backprop(TYPE learning_rate,
                  int32_t tsamps_perbatch,
                  int32_t num_windows,
                  int32_t iters_perbatch,
                  int32_t input_dimension,
                  int32_t layer1_dimension,
                  int32_t W_size,
                  int32_t batch,
                  bool flag[],
                  bool ping);

    void thresh_update_scalar(int32_t num_windows,
                              int32_t window_size,
                              TYPE rate_spike,
                              TYPE rate_noise,
                              TYPE spike_weight);

    void thresh_update_vector(int32_t num_windows,
                              int32_t window_size,
                              TYPE rate_spike,
                              TYPE rate_noise,
                              TYPE spike_weight);
    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> plm_in_ping[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_in_pong[PLM_IN_WORD];
    // deleted output pingpong
    sc_dt::sc_int<DATA_WIDTH> plm_out[PLM_OUT_WORD];
    // for relevancy detection
    sc_dt::sc_int<DATA_WIDTH> plm_maxmin[PLM_ELEC_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_mean_spike[PLM_ELEC_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_mean_noise[PLM_ELEC_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_thresh[PLM_ELEC_WORD];

    // flattened arrays
    bool flag[CONST_NUM_WINDOWS];

    // for detection buffer coordination
    // TODO revisit this
    // sc_bv<4> full;

};


#endif /* __MINDFUZZ_HPP__ */
