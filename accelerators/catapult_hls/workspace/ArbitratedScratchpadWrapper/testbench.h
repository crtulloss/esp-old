#ifndef __TESTBENCH_H__
#define __TESTBENCH_H__

#include "dummy.h"
#include "stimuli.h"
#include "config.h"

#include <connections/connections.h>

#include <systemc.h>

SC_MODULE (Testbench) {

    // Clock and reset ports
    sc_clock clk;
    sc_signal<bool> rst;

    // Constructor
    SC_CTOR(Testbench) :
        clk("clk", 1, SC_NS, 0.5, 0, SC_NS, true),
        rst("rst"),
        data_in("data_in"),
        data_out("data_out"),
        dut("dut"),
        stimuli("stimuli")
    {
        // Module bindings
        dut.clk(clk);
        dut.rst(rst);
        dut.data_in(data_in);
        dut.data_out(data_out);

        stimuli.clk(clk);
        stimuli.rst(rst);
        stimuli.data_in(data_in);
        stimuli.data_out(data_out);

        SC_THREAD(init);
    }

    // Internal connections
    Connections::Combinational<data32_t> data_in;
    Connections::Combinational<data32_t> data_out;

    // Modules
    Dummy dut;
    Stimuli stimuli;

    // Processes
    void init();
};

#endif
