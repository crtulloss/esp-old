// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SHA1_CXX_H__
#define __SHA1_CXX_H__

#include "data_types.h"   // Data types
#include "conf_info.hpp"  // Configuration-port data type

#include <ac_channel.h>   // Algorithmic C channel class
#include <ac_sync.h>

#include "defines.h"

// NoC-/Accelerator-interface dimensions
#define DMA_WIDTH 64
#define DMA_SIZE SIZE_DWORD

typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define SHA1_MAX_BLOCK_SIZE 131072
const int sha1_max_addr_mem = 131072;

#define DATA_WIDTH 8
#define PLM_IN_SIZE SHA1_MAX_BLOCK_SIZE
#define PLM_OUT_SIZE SHA1_DIGEST_LENGTH

#define BATCH_MAX 16

// Private Local Memory
// Encapsulate the PLM array in a templated struct
template <class T, unsigned S>
struct plm_struct_t {
public:
   T data[S];
};

// PLM typedefs
typedef plm_struct_t<data_t, PLM_IN_SIZE> plm_in_t;
typedef plm_struct_t<data_t, PLM_OUT_SIZE> plm_out_t;

// Accelerator top module
void sha1_cxx(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &acc_done);

#endif // __SHA1_CXX_H__
