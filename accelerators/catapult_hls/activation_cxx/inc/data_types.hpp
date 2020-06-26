// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DATA_TYPES_HPP__
#define __DATA_TYPES_HPP__

#include "ac_fixed.h"

#define FX_WIDTH 32

#define SOFTMAX_FX32_IN_IL 6
#define SOFTMAX_FX32_OUT_IL 2

#define TAHN_FX32_IN_IL 6
#define TAHN_FX32_OUT_IL 2

#define SIGMOID_FX32_IN_IL 6
#define SIGMOID_FX32_OUT_IL 6

#define RELU_FX32_IN_IL 6
#define RELU_FX32_OUT_IL 2

// Data types

const unsigned int WORD_SIZE = FX_WIDTH;

const unsigned int FPDATA_WL = FX_WIDTH;

const unsigned int SOFTMAX_FPDATA_IN_IL = SOFTMAX_FX32_IN_IL;
const unsigned int SOFTMAX_FPDATA_OUT_IL = SOFTMAX_FX32_OUT_IL;
const unsigned int TAHN_FPDATA_IN_IL = TAHN_FX32_IN_IL;
const unsigned int TAHN_FPDATA_OUT_IL = TAHN_FX32_OUT_IL;
const unsigned int SIGMOID_FPDATA_IN_IL = SIGMOID_FX32_IN_IL;
const unsigned int SIGMOID_FPDATA_OUT_IL = SIGMOID_FX32_OUT_IL;
const unsigned int RELU_FPDATA_IN_IL = RELU_FX32_IN_IL;
const unsigned int RELU_FPDATA_OUT_IL = RELU_FX32_OUT_IL;

typedef ac_int<WORD_SIZE> FPDATA_WORD;

typedef ac_fixed<FPDATA_WL, SOFTMAX_FPDATA_IN_IL, true, AC_TRN, AC_WRAP> SOFTMAX_FPDATA_IN;
typedef ac_fixed<FPDATA_WL, SOFTMAX_FPDATA_OUT_IL, false, AC_TRN, AC_WRAP> SOFTMAX_FPDATA_OUT;
typedef ac_fixed<FPDATA_WL, TAHN_FPDATA_IN_IL, true, AC_TRN, AC_WRAP> TAHN_FPDATA_IN;
typedef ac_fixed<FPDATA_WL, TAHN_FPDATA_OUT_IL, false, AC_TRN, AC_WRAP> TAHN_FPDATA_OUT;
typedef ac_fixed<FPDATA_WL, SIGMOID_FPDATA_IN_IL, true, AC_TRN, AC_WRAP> SIGMOID_FPDATA_IN;
typedef ac_fixed<FPDATA_WL, SIGMOID_FPDATA_OUT_IL, false, AC_TRN, AC_WRAP> SIGMOID_FPDATA_OUT;
typedef ac_fixed<FPDATA_WL, RELU_FPDATA_IN_IL, true, AC_TRN, AC_WRAP> RELU_FPDATA_IN;
typedef ac_fixed<FPDATA_WL, RELU_FPDATA_OUT_IL, false, AC_TRN, AC_WRAP> RELU_FPDATA_OUT;

#endif // __DATA_TYPES_HPP__
