#ifndef __STIMULI_H__
#define __STIMULI_H__

#include "data_types.h"

#include <hls_globals.h>

#include <nvhls_connections.h>
#include <testbench/nvhls_rand.h>

#include <systemc.h>
#include <deque>
#include <fifo.h>

typedef std::deque<data32_t> Fifo;

// Input and Output for Testbench
SC_MODULE (Stimuli) {

    // Clock and reset ports
    sc_in_clk clk;
    sc_in <bool> rst;

    // Data ports
    Connections::Out<data32_t> data_in;
    Connections::In<data32_t> data_out;

    // Constructor
    SC_HAS_PROCESS(Stimuli);
    Stimuli(sc_module_name name) : sc_module(name),
    clk("clk"),
    rst("rst"),
    data_in("data_in"),
    data_out("data_out")
    {
        SC_THREAD(source);
        sensitive << clk.pos();
        reset_signal_is(rst, false);

        SC_THREAD(sink);
        sensitive << clk.pos();
        reset_signal_is(rst, false);
    }

    // Testbench bookkeeping
    Fifo fifo;

    // Processes
    void source();
    void sink();
};

#endif
