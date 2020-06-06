// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SOFTMAX_FPDATA_HPP__
#define __SOFTMAX_FPDATA_HPP__

#include "ac_fixed.h"

#define FX_WIDTH 32
#define FX32_IN_IL 6 
#define FX32_OUT_IL 2 

// Data types

const unsigned int WORD_SIZE = FX_WIDTH;

const unsigned int FPDATA_WL = FX_WIDTH;

const unsigned int FPDATA_IN_IL = FX32_IN_IL;

const unsigned int FPDATA_OUT_IL = FX32_OUT_IL;

const unsigned int FPDATA_IN_PL = (FPDATA_WL - FPDATA_IN_IL);

const unsigned int FPDATA_OUT_PL = (FPDATA_WL - FPDATA_OUT_IL);

typedef ac_int<WORD_SIZE> FPDATA_WORD;

typedef ac_fixed<FPDATA_WL, FPDATA_IN_IL, true, AC_TRN, AC_WRAP> FPDATA_IN;

typedef ac_fixed<FPDATA_WL, FPDATA_OUT_IL, false, AC_TRN, AC_WRAP> FPDATA_OUT;

#endif // __SOFTMAX_FPDATA_HPP__
