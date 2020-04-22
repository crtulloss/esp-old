// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SOFTMAX_CONF_INFO_HPP__
#define __SOFTMAX_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator
//
class conf_info_t {
public:

    // Constructor
    conf_info_t() : size(0), batch(0){}

    // Equal operator
    inline bool operator==(const conf_info_t &rhs) const {
        return (size == rhs.size && batch == rhs.batch && in_offset == rhs.in_offset && out_offset == rhs.out_offset);
    }

    // Assignment operator
    inline conf_info_t& operator=(const conf_info_t& other) {
        size = other.size;
        batch = other.batch;
        in_offset = other.in_offset;
        out_offset = other.out_offset;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME) {}

    // Redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info) {
        os << "{ size = " << conf_info.size << ", batch = " << conf_info.batch << ", in_offset = " << conf_info.in_offset << ", out_offset = " << conf_info.out_offset  << "}";
        return os;
    }

    // Parameters
    uint32_t size;
    uint32_t batch;
    uint32_t in_offset;
    uint32_t out_offset;
};

#endif // __SOFTMAX_CONF_INFO_HPP__
