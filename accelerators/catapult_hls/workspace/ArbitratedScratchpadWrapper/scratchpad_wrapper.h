#ifndef __SCRATCHPAD_WRAPPER_H__
#define __SCRATCHPAD_WRAPPER_H__

#include "data_types.h"

#define HLS_ALGORITHMICC
#include <ArbitratedScratchpad.h>     // MatchLib
#include <connections/connections.h>  // Mentor

#define NUM_BANK_ENTRIES 1024 // in bytes
#define NUM_BANK_WORDS (NUM_BANK_ENTRIES / size_of_data32_t)
#define NUM_BANKS 2
#define NUM_INPUTS 2
#define LEN_INPUT_BUFFER 0
#define SCRATCHPAD_CAPACITY (NUM_BANK_ENTRIES * NUM_BANKS) // in bytes
#define SCRATCHPAD_CAPACITY_IN_WORDS (NUM_BANK_WORDS * NUM_BANKS)
#define SCRATCHPAD_ADDR_WIDTH nvhls::nbits<SCRATCHPAD_CAPACITY-1>::val


typedef cli_req_t<data32_t, SCRATCHPAD_ADDR_WIDTH, 1> req_t;
typedef cli_rsp_t<data32_t, 1> rsp_t;

SC_MODULE (ScratchpadWrapper) {

    // Clock and reset ports.
    sc_in_clk clk;
    sc_in <bool> rst;

    // Data req/resp ports.
    Connections::In<req_t> req_port_01;
    Connections::Out<rsp_t> resp_port_01;
    Connections::In<req_t> req_port_02;
    Connections::Out<rsp_t> resp_port_02;

    // Constructor.
    SC_HAS_PROCESS(ScratchpadWrapper);
    ScratchpadWrapper(sc_module_name name):
        sc_module(name),
        clk("clk"),
        rst("rst"),
        req_port_01("req_port_01"),
        resp_port_01("resp_port_01"),
        req_port_02("req_port_02"),
        resp_port_02("resp_port_02"),
        req_wrapper_01("req_wrapper_01"),
        resp_wrapper_01("resp_wrapper_01"),
        req_wrapper_02("req_wrapper_02"),
        resp_wrapper_02("resp_wrapper_02")
    {
        SC_CTHREAD(wrapper, clk.pos());
        reset_signal_is(rst, false);

        SC_CTHREAD(thread_port_01, clk.pos());
        reset_signal_is(rst, false);

        SC_CTHREAD(thread_port_02, clk.pos());
        reset_signal_is(rst, false);
    }

    // Internal connections.
    Connections::Combinational<req_t> req_wrapper_01;
    Connections::Combinational<rsp_t> resp_wrapper_01;

    Connections::Combinational<req_t> req_wrapper_02;
    Connections::Combinational<rsp_t> resp_wrapper_02;

    // Memory element(s).
    //static const int N = SCRATCHPAD_BANKS;
    //static const int CAPACITY_IN_BYTES = SCRATCHPAD_CAPACITY ;
    //static const int ADDR_WIDTH = SCRATCHPAD_ADDR_WIDTH;
    ArbitratedScratchpad<data32_t, SCRATCHPAD_CAPACITY, NUM_INPUTS, NUM_BANKS, LEN_INPUT_BUFFER> scratchpad;

    // Processes.
    void wrapper();
    void thread_port_01();
    void thread_port_02();
};

#endif
