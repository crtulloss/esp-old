// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MINDFUZZ_DIRECTIVES_HPP__
#define __MINDFUZZ_DIRECTIVES_HPP__

// added by CRT - related to datatypes
// use fixed point data type
#define FX_WIDTH 32
#define FX64_IL 15
#define FX32_IL 15
#define FX16_IL 8 // TODO what is the correct length?

// to test whether applying learning rate in stages gives same result
// as single learning rate
#define split_LR
// testing beh using fixed point
#define HLS_FP


// for ASIC synth with no memory banks
//#define ASIC_FLATTEN




#if (FX_WIDTH == 32)

#if (DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 1
#define PLM_IN_NAME "mindfuzz_plm_block_in_dma32"
#define PLM_OUT_NAME "mindfuzz_plm_block_out_dma32"
#elif (DMA_WIDTH == 64)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 2
#define PLM_IN_NAME "mindfuzz_plm_block_in_dma64"
#define PLM_OUT_NAME "mindfuzz_plm_block_out_dma64"
#endif

#define PLM_ELEC_NAME "mindfuzz_plm_block_elec_32"

#else // 16

#if (DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 2
#define PLM_IN_NAME "mindfuzz_plm_block_in_16_dma32"
#define PLM_OUT_NAME "mindfuzz_plm_block_out_16_dma32"
#elif (DMA_WIDTH == 64)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 4
#define PLM_IN_NAME "mindfuzz_plm_block_in_16_dma64"
#define PLM_OUT_NAME "mindfuzz_plm_block_out_16_dma64"
#endif

#define PLM_ELEC_NAME "mindfuzz_plm_block_elec_16"

#endif

#if defined(STRATUS_HLS)

// auto generated stuff
#define HLS_MAP_plm(_mem, _plm_block_name)      \
    HLS_MAP_TO_MEMORY(_mem, _plm_block_name)

#define HLS_PROTO(_s)                           \
    HLS_DEFINE_PROTOCOL(_s)

#define HLS_FLAT(_a)                            \
    HLS_FLATTEN_ARRAY(_a);

#define HLS_BREAK_DEP(_a)                       \
    HLS_BREAK_ARRAY_DEPENDENCY(_a)

#define HLS_UNROLL_SIMPLE                       \
    HLS_UNROLL_LOOP(ON)

#if defined(HLS_DIRECTIVES_BASIC)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_MAP_plm(_mem, _plm_block_name)
#define HLS_PROTO(_s)
#define HLS_FLAT(_a)
#define HLS_BREAK_DEP(_a)
#define HLS_UNROLL_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __MINDFUZZ_DIRECTIVES_HPP_ */
