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
    conf_info_t() : batch(0){}

    // Equal operator
    inline bool operator==(const conf_info_t &rhs) const {
        return (batch == rhs.batch);
    }

    // Assignment operator
    inline conf_info_t& operator=(const conf_info_t& other) {
        batch = other.batch;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME) {}

    // Redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info) {
        os << "{ batch = " << conf_info.batch << "}";
        return os;
    }

    // Parameters
    uint32_t batch;
};

#endif // __SOFTMAX_CONF_INFO_HPP__
