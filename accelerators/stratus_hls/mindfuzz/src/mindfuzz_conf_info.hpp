// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MINDFUZZ_CONF_INFO_HPP__
#define __MINDFUZZ_CONF_INFO_HPP__

#include <systemc.h>

// TODO fix learning_rate and detect_threshold

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:

    //
    // constructors
    //
    conf_info_t()
    {
        /* <<--ctor-->> */
        this->do_relu = 0;
        this->window_size = 4;
        this->batches_perindata = 1;
        this->learning_rate = 0.01;
        this->neurons_perwin = 1;
        this->tsamps_perbatch = 32;
        this->detect_threshold = 0.9;
        this->num_windows = 8;
        this->epochs_perbatch = 1;
        this->num_batches = 128;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t do_relu, 
        int32_t window_size, 
        int32_t batches_perindata, 
        int32_t learning_rate, 
        int32_t neurons_perwin, 
        int32_t tsamps_perbatch, 
        int32_t detect_threshold, 
        int32_t num_windows, 
        int32_t epochs_perbatch, 
        int32_t num_batches
        )
    {
        /* <<--ctor-custom-->> */
        this->do_relu = do_relu;
        this->window_size = window_size;
        this->batches_perindata = batches_perindata;
        this->learning_rate = learning_rate;
        this->neurons_perwin = neurons_perwin;
        this->tsamps_perbatch = tsamps_perbatch;
        this->detect_threshold = detect_threshold;
        this->num_windows = num_windows;
        this->epochs_perbatch = epochs_perbatch;
        this->num_batches = num_batches;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (do_relu != rhs.do_relu) return false;
        if (window_size != rhs.window_size) return false;
        if (batches_perindata != rhs.batches_perindata) return false;
        if (learning_rate != rhs.learning_rate) return false;
        if (neurons_perwin != rhs.neurons_perwin) return false;
        if (tsamps_perbatch != rhs.tsamps_perbatch) return false;
        if (detect_threshold != rhs.detect_threshold) return false;
        if (num_windows != rhs.num_windows) return false;
        if (epochs_perbatch != rhs.epochs_perbatch) return false;
        if (num_batches != rhs.num_batches) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        do_relu = other.do_relu;
        window_size = other.window_size;
        batches_perindata = other.batches_perindata;
        learning_rate = other.learning_rate;
        neurons_perwin = other.neurons_perwin;
        tsamps_perbatch = other.tsamps_perbatch;
        detect_threshold = other.detect_threshold;
        num_windows = other.num_windows;
        epochs_perbatch = other.epochs_perbatch;
        num_batches = other.num_batches;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
    {}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
    {
        os << "{";
        /* <<--print-->> */
        os << "do_relu = " << conf_info.do_relu << ", ";
        os << "window_size = " << conf_info.window_size << ", ";
        os << "batches_perindata = " << conf_info.batches_perindata << ", ";
        os << "learning_rate = " << conf_info.learning_rate << ", ";
        os << "neurons_perwin = " << conf_info.neurons_perwin << ", ";
        os << "tsamps_perbatch = " << conf_info.tsamps_perbatch << ", ";
        os << "detect_threshold = " << conf_info.detect_threshold << ", ";
        os << "num_windows = " << conf_info.num_windows << ", ";
        os << "epochs_perbatch = " << conf_info.epochs_perbatch << ", ";
        os << "num_batches = " << conf_info.num_batches << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t do_relu;
        int32_t window_size;
        int32_t batches_perindata;
        int32_t learning_rate;
        int32_t neurons_perwin;
        int32_t tsamps_perbatch;
        int32_t detect_threshold;
        int32_t num_windows;
        int32_t epochs_perbatch;
        int32_t num_batches;
};

#endif // __MINDFUZZ_CONF_INFO_HPP__
