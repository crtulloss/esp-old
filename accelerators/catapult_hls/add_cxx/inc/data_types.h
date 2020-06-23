// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DATA_HPP__
#define __DATA_HPP__

// TODO DO NOT USE >stdint.h>, YOU SHOULD REDEFINE THE STD TYPES!
//#include <stdint.h>

#include "esp_headers.hpp" // ESP-common headers

const unsigned int WORD_SIZE = 64;

typedef ac_int<WORD_SIZE, false> DATA_WORD;

#endif // __DATA_HPP__
