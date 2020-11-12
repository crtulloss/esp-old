// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MINDFUZZ_CONF_INFO_HPP__
#define __MINDFUZZ_CONF_INFO_HPP__

#include <systemc.h>

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
        this->window_size = 4;
        this->batches_perload = 1;
        this->learning_rate = a_write(0.01);
        this->neurons_perwin = 1;
        this->tsamps_perbatch = 32;
        this->num_windows = 8;
        this->iters_perbatch = 1;
        this->num_loads = 128;
        this->rate_spike = a_write(0.01);
        this->rate_noise = a_write(0.01);
        this->spike_weight = a_write(0.5);
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t window_size, 
        int32_t batches_perload, 
        int32_t learning_rate, 
        int32_t neurons_perwin, 
        int32_t tsamps_perbatch, 
        int32_t num_windows, 
        int32_t iters_perbatch, 
        int32_t num_loads,
        int32_t rate_spike,
        int32_t rate_noise,
        int32_t spike_weight
        )
    {
        /* <<--ctor-custom-->> */
        this->window_size = window_size;
        this->batches_perload = batches_perload;
        this->learning_rate = learning_rate;
        this->neurons_perwin = neurons_perwin;
        this->tsamps_perbatch = tsamps_perbatch;
        this->num_windows = num_windows;
        this->iters_perbatch = iters_perbatch;
        this->num_loads = num_loads;
        this->rate_spike = rate_spike;
        this->rate_noise = rate_noise;
        this->spike_weight = spike_weight;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (window_size != rhs.window_size) return false;
        if (batches_perload != rhs.batches_perload) return false;
        if (learning_rate != rhs.learning_rate) return false;
        if (neurons_perwin != rhs.neurons_perwin) return false;
        if (tsamps_perbatch != rhs.tsamps_perbatch) return false;
        if (num_windows != rhs.num_windows) return false;
        if (iters_perbatch != rhs.iters_perbatch) return false;
        if (num_loads != rhs.num_loads) return false;
        if (rate_spike != rhs.rate_spike) return false;
        if (rate_noise != rhs.rate_noise) return false;
        if (spike_weight != rhs.spike_weight) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        window_size = other.window_size;
        batches_perload = other.batches_perload;
        learning_rate = other.learning_rate;
        neurons_perwin = other.neurons_perwin;
        tsamps_perbatch = other.tsamps_perbatch;
        num_windows = other.num_windows;
        iters_perbatch = other.iters_perbatch;
        num_loads = other.num_loads;
        rate_spike = other.rate_spike;
        rate_noise = other.rate_noise;
        spike_weight = other.spike_weight;
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
        os << "window_size = " << conf_info.window_size << ", ";
        os << "batches_perload = " << conf_info.batches_perload << ", ";
        os << "learning_rate = " << a_read(conf_info.learning_rate) << ", ";
        os << "neurons_perwin = " << conf_info.neurons_perwin << ", ";
        os << "tsamps_perbatch = " << conf_info.tsamps_perbatch << ", ";
        os << "num_windows = " << conf_info.num_windows << ", ";
        os << "iters_perbatch = " << conf_info.iters_perbatch << ", ";
        os << "num_loads = " << conf_info.num_loads << "";
        os << "rate_spike = " << a_read(conf_info.rate_spike) << "";
        os << "rate_noise = " << a_read(conf_info.rate_noise) << "";
        os << "spike_weight = " << a_read(conf_info.spike_weight) << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t window_size;
        int32_t batches_perload;
        int32_t learning_rate;
        int32_t neurons_perwin;
        int32_t tsamps_perbatch;
        int32_t num_windows;
        int32_t iters_perbatch;
        int32_t num_loads;
        int32_t rate_spike;
        int32_t rate_noise;
        int32_t spike_weight;
};

#endif // __MINDFUZZ_CONF_INFO_HPP__
