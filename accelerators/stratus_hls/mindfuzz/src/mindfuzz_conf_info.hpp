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
        this->hiddens_perwin = 1;
        this->tsamps_perbatch = 32;
        this->num_windows = 8;
        this->iters_perbatch = 1;
        this->num_loads = 128;
        this->rate_mean = a_write(0.01);
        this->rate_variance = a_write(0.01);
        this->do_init = true;
        this->do_backprop = true;
        this->do_thresh_update = true;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t window_size, 
        int32_t batches_perload, 
        int32_t learning_rate, 
        int32_t hiddens_perwin, 
        int32_t tsamps_perbatch, 
        int32_t num_windows, 
        int32_t iters_perbatch, 
        int32_t num_loads,
        int32_t rate_mean,
        int32_t rate_variance,
        bool do_init,
        bool do_backprop,
        bool do_thresh_update
        )
    {
        /* <<--ctor-custom-->> */
        this->window_size = window_size;
        this->batches_perload = batches_perload;
        this->learning_rate = learning_rate;
        this->hiddens_perwin = hiddens_perwin;
        this->tsamps_perbatch = tsamps_perbatch;
        this->num_windows = num_windows;
        this->iters_perbatch = iters_perbatch;
        this->num_loads = num_loads;
        this->rate_mean = rate_mean;
        this->rate_variance = rate_variance;
        this->do_init = do_init;
        this->do_backprop = do_backprop;
        this->do_thresh_update = do_thresh_update;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (window_size != rhs.window_size) return false;
        if (batches_perload != rhs.batches_perload) return false;
        if (learning_rate != rhs.learning_rate) return false;
        if (hiddens_perwin != rhs.hiddens_perwin) return false;
        if (tsamps_perbatch != rhs.tsamps_perbatch) return false;
        if (num_windows != rhs.num_windows) return false;
        if (iters_perbatch != rhs.iters_perbatch) return false;
        if (num_loads != rhs.num_loads) return false;
        if (rate_mean != rhs.rate_mean) return false;
        if (rate_variance != rhs.rate_variance) return false;
        if (do_init != rhs.do_init) return false;
        if (do_backprop != rhs.do_backprop) return false;
        if (do_thresh_update != rhs.do_thresh_update) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        window_size = other.window_size;
        batches_perload = other.batches_perload;
        learning_rate = other.learning_rate;
        hiddens_perwin = other.hiddens_perwin;
        tsamps_perbatch = other.tsamps_perbatch;
        num_windows = other.num_windows;
        iters_perbatch = other.iters_perbatch;
        num_loads = other.num_loads;
        rate_mean = other.rate_mean;
        rate_variance = other.rate_variance;
        do_init = other.do_init;
        do_backprop = other.do_backprop;
        do_thresh_update = other.do_thresh_update;
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
        os << "hiddens_perwin = " << conf_info.hiddens_perwin << ", ";
        os << "tsamps_perbatch = " << conf_info.tsamps_perbatch << ", ";
        os << "num_windows = " << conf_info.num_windows << ", ";
        os << "iters_perbatch = " << conf_info.iters_perbatch << ", ";
        os << "num_loads = " << conf_info.num_loads << "";
        os << "rate_mean = " << a_read(conf_info.rate_mean) << "";
        os << "rate_variance = " << a_read(conf_info.rate_variance) << "";
        os << "do_init = " << conf_info.do_init << "";
        os << "do_backprop = " << conf_info.do_backprop << "";
        os << "do_thresh_update = " << conf_info.do_thresh_update << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t window_size;
        int32_t batches_perload;
        int32_t learning_rate;
        int32_t hiddens_perwin;
        int32_t tsamps_perbatch;
        int32_t num_windows;
        int32_t iters_perbatch;
        int32_t num_loads;
        int32_t rate_mean;
        int32_t rate_variance;
        bool do_init;
        bool do_backprop;
        bool do_thresh_update;
};

#endif // __MINDFUZZ_CONF_INFO_HPP__
