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
#if (FX_WIDTH == 16)

#define DATA_WIDTH 16

#else // 32

#define DATA_WIDTH 32

#endif // 16 vs 32

#define DMA_SIZE SIZE_HWORD

//#define PLM_OUT_WORD 2432
//#define PLM_IN_WORD 65536

// TODO formalize these as the maximum sizes so they can be used for array sizing e.g. flag array
// macro versions of some config parameters, in case we don't want them configable
#define CONST_NUM_WINDOWS 1
#define CONST_WINDOW_SIZE 32
#define CONST_HIDDENS_PERWIN 6
#define CONST_TSAMPS_PERBATCH 90
#define CONST_BATCHES_PERLOAD 1

// new sizes for one-window test
#define PLM_OUT_WORD CONST_NUM_WINDOWS*CONST_WINDOW_SIZE*CONST_HIDDENS_PERWIN
#define PLM_IN_WORD CONST_NUM_WINDOWS*CONST_WINDOW_SIZE*CONST_TSAMPS_PERBATCH*CONST_BATCHES_PERLOAD
#define PLM_ELEC_WORD CONST_NUM_WINDOWS*CONST_WINDOW_SIZE

// useful macros for splitting up learning rate multiplications to preserve dynamic range
#ifdef split_LR

// define fractional powers of 2
#define frac_4 ((TYPE)0.25)
#define frac_64 ((TYPE)0.015625)
#define frac_128 ((TYPE)0.0078125)
#define frac_256 ((TYPE)0.00390625)
#define frac_512 ((TYPE)0.001953125)
#define frac_1024 ((TYPE)0.0009765625)
#define frac_2048 ((TYPE)0.00048828125)
#define frac_4096 ((TYPE)0.0002441406125)

// choose which shifts to use
#if (FX_WIDTH == 16)

#define shift_A frac_256
#define shift_up_C ((TYPE)1)
#define shift_down_C ((TYPE)1)

#define bs_A 8
#define numerator_B 4
#define bs_C 0

#else // 32

#define shift_A frac_2048
#define numerator_B 128
#define shift_up_C ((TYPE)128)
#define shift_down_C frac_128
// actual bit shift versions
#define bs_A 11
#define bs_C 7

#endif // 16 vs 32

#endif

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
        HLS_MAP_plm(plm_mean, PLM_ELEC_NAME);
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
    void relevant(uint8_t total_tsamps,
                  uint16_t num_windows,
                  uint8_t window_size,
                  bool flag[],
                  bool ping);

    void backprop(TYPE learning_rate,
                  uint8_t tsamps_perbatch,
                  uint16_t num_windows,
                  uint8_t iters_perbatch,
                  uint8_t input_dimension,
                  uint8_t layer1_dimension,
                  uint32_t W_size,
                  uint8_t batch,
                  bool flag[],
                  bool ping);
/*
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
*/
    void thresh_update_variance(uint16_t num_windows,
                                uint8_t window_size,
                                TYPE rate_mean,
                                TYPE rate_variance);

    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> plm_in_ping[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_in_pong[PLM_IN_WORD];
    // deleted output pingpong
    sc_dt::sc_int<DATA_WIDTH> plm_out[PLM_OUT_WORD];
    // for relevancy detection
    sc_dt::sc_int<DATA_WIDTH> plm_maxmin[PLM_ELEC_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_mean[PLM_ELEC_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_thresh[PLM_ELEC_WORD];

    // flattened arrays
    bool flag[CONST_NUM_WINDOWS];

    // for detection buffer coordination
    // TODO revisit this
    // sc_bv<4> full;

};


#endif /* __MINDFUZZ_HPP__ */
