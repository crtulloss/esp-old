// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __ACTIVATION_CXX_HPP__
#define __ACTIVATION_CXX_HPP__

#include "data_types.hpp" // Fixed-point data types
#include "conf_info.hpp"  // Configuration-port data type

#include <ac_channel.h>   // Algorithmic C channel class
#include <ac_sync.h>

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
typedef plm_t<SOFTMAX_FPDATA_IN, PLM_SIZE> plm_in_t;
typedef plm_t<SOFTMAX_FPDATA_OUT, PLM_SIZE> plm_out_t;

// Accelerator top module
void activation_cxx(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &acc_done);

#endif /* __ACTIVATION_CXX_HPP__ */
