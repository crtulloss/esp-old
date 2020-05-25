// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SOFTMAX_CXX_HPP__
#define __SOFTMAX_CXX_HPP__

#include "fpdata.hpp"     // Fixed-point data types
#include "conf_info.hpp"  // Configuration-port data type
#include "debug_info.hpp" // Debug-port data type

#include <ac_channel.h>   // Algorithmic C channel class

// NoC-/Accelerator-interface dimensions
#define DMA_WIDTH 64
#define DMA_SIZE SIZE_DWORD 

typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define DATA_WIDTH 32
#define PLM_SIZE 128

#define BATCH_MAX 16

// Private Local Memory
// Encapsulate the PLM array in a templated struct
template <class T, unsigned S>
struct plm_t {
public:
   T data[S];
};

// PLM typedefs
typedef plm_t<FPDATA_IN, PLM_SIZE> plm_in_t;
typedef plm_t<FPDATA_OUT, PLM_SIZE> plm_out_t;

// Accelerator top module
void softmax_cxx(
        debug_info_t &debug,
        conf_info_t conf_info,
        bool conf_done,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl);

#endif /* __SOFTMAX_CXX_HPP__ */
