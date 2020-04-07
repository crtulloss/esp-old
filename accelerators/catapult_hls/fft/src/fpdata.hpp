// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __NMF_FPDATA_HPP__
#define __NMF_FPDATA_HPP__

#include <cstdio>
#include <cstdlib>
#include <cstddef>
#include <systemc.h>

// Catapult HLS fixed point

#include "ac_fixed.h"

// Data types

const unsigned int WORD_SIZE = FX_WIDTH;

const unsigned int FPDATA_WL = FX_WIDTH;

#if (FX_WIDTH==64)
const unsigned int FPDATA_IL = FX64_IL;
#elif (FX_WIDTH==32)
const unsigned int FPDATA_IL = FX32_IL;
#endif // FX_WIDTH

const unsigned int FPDATA_PL = (FPDATA_WL - FPDATA_IL);


typedef ac_int<WORD_SIZE> FPDATA_WORD;

typedef ac_fixed<FPDATA_WL, FPDATA_IL, AC_RND> FPDATA;

class CompNum { // a complex number
public:
    FPDATA re;   // the real part
    FPDATA im;   // the imaginary part

    CompNum() {
        re = 0;
        im = 0;
    }

    CompNum(FPDATA real, FPDATA imaginary) {
        re = real;
        im = imaginary;
    }
};


// Helper functions

template<typename T, size_t N>
T bv2fp(sc_dt::sc_bv<N> data_in)
{
    T data_out;

    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "bv2fp1");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "bv2fp-loop");
//#warning "HLS_UNROLL"
            data_out[i] = data_in[i].to_bool();
        }
    }

    return data_out;
}

template<typename T, size_t N>
void bv2fp(T &data_out, sc_dt::sc_bv<N> data_in)
{
    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "bv2fp2");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "bv2fp-loop");
//#warning "HLS_UNROLL"

            data_out[i] = data_in[i].to_bool();
        }
    }
}

template<typename T, size_t N>
sc_dt::sc_bv<N> fp2bv(T data_in)
{
    sc_dt::sc_bv<N> data_out;

    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2bv1");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "fp2bv-loop");
//#warning "HLS_UNROLL"

            data_out[i] = (bool) data_in[i];
        }
    }

    return data_out;
}

template<typename T, size_t N>
void fp2bv(sc_dt::sc_bv<N> &data_out, T data_in)
{
    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2bv2");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "fp2bv-loop");
//#warning "HLS_UNROLL"

            data_out[i] = (bool) data_in[i];
        }
    }
}

// Helper functions

// T <---> ac_int<N>

template<typename T, size_t N>
T int2fp(ac_int<N> data_in)
{
    T data_out;

    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "int2fp1");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "int2fp-loop");
//#warning "HLS_UNROLL"

            data_out[i] = data_in[i];
        }
    }

    return data_out;
}

template<typename T, size_t N>
void int2fp(T &data_out, ac_int<N> data_in)
{
    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "int2fp2");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "int2fp-loop");
//#warning "HLS_UNROLL"

            data_out[i] = data_in[i].to_bool();
        }
    }
}

template<typename T, size_t N>
ac_int<N> fp2int(T data_in)
{
    ac_int<N> data_out;

    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2int1");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "fp2int-loop");
//#warning "HLS_UNROLL"

            data_out[i] = (bool) data_in[i];
        }
    }

    return data_out;
}

template<typename T, size_t N>
void fp2int(ac_int<N> &data_out, T data_in)
{
    {
        //HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2int2");
//#warning "HLS_CONSTRAINT_LATENCY"

        for (unsigned i = 0; i < N; i++)
        {
            //HLS_UNROLL_LOOP(ON, "fp2int-loop");
//#warning "HLS_UNROLL"

            data_out[i] = (bool) data_in[i];
        }
    }
}

#endif // __NMF_FPDATA_HPP__
