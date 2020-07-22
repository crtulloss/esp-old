#ifndef __DUMMY_H__
#define __DUMMY_H__

#include <systemc.h>

#include "data_types.h"
#include "handshake.h"

#include "arbitrated_scratchpad_dp_wrapper.h"

SC_MODULE (Dummy) {

    // Clock and reset ports
    sc_in_clk clk;
    sc_in <bool> rst;

    // Data ports
    Connections::In<data32_t> data_in;
    Connections::Out<data32_t> data_out;

    // Constructor
    SC_HAS_PROCESS(Dummy);
    Dummy(sc_module_name name):
        sc_module(name),
        clk("clk"),
        rst("rst"),
        data_in("data_in"),
        data_out("data_out"),
        req_port_01("req_port_01"),
        rsp_port_01("rsp_port_01"),
        req_port_02("req_port_02"),
        rsp_port_02("rsp_port_02"),
        scratchpad_wrapper("scratchpad_wrapper"),
        handshake("handshake")
    {
        // PLM port bindings
        scratchpad_wrapper.clk(clk);
        scratchpad_wrapper.rst(rst);
        scratchpad_wrapper.req_port_01(req_port_01);
        scratchpad_wrapper.rsp_port_01(rsp_port_01);
        scratchpad_wrapper.req_port_02(req_port_02);
        scratchpad_wrapper.rsp_port_02(rsp_port_02);
        SC_CTHREAD(producer, clk.pos());
        reset_signal_is(rst, false);

        SC_CTHREAD(consumer, clk.pos());
        reset_signal_is(rst, false);
    }

    // Internal connections
    Connections::Combinational<req_t> req_port_01;
    Connections::Combinational<rsp_t> rsp_port_01;
    Connections::Combinational<req_t> req_port_02;
    Connections::Combinational<rsp_t> rsp_port_02;

    // Private local memory (PLM)
    ScratchpadWrapper scratchpad_wrapper;

    // Handshake signals
    handshake_t handshake;

    // Processes
    void producer();
    void consumer();
};

#endif
