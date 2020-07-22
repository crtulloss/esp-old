#include "dummy.h"
#include "utils.h"
#include "data_types.h"
#include "config.h"

#include <hls_globals.h>
#include <nvhls_connections.h>
#include <testbench/nvhls_rand.h>
#include <fifo.h>

#include <systemc.h>
#include <deque>

typedef std::deque<data32_t> Fifo;

// Input and Output for Testbench
SC_MODULE (Stimuli) {
    sc_in_clk clk;
    sc_in <bool> rst;
    Connections::Out<data32_t> data_in;
    Connections::In<data32_t> data_out;

    Fifo fifo;

    void source();
    void sink();

    SC_HAS_PROCESS(Stimuli);
    Stimuli(sc_module_name name) : sc_module(name),
    clk("clk"),
    rst("rst"),
    data_in("data_in"),
    data_out("data_out")
    {
        SC_THREAD(source);
        sensitive << clk.pos();
        NVHLS_NEG_RESET_SIGNAL_IS(rst);

        SC_THREAD(sink);
        sensitive << clk.pos();
        NVHLS_NEG_RESET_SIGNAL_IS(rst);
    }
};


void Stimuli::source() {
    fifo.clear();

    data_in.Reset();

    wait(2, SC_NS);

    REPORT_TIME(VON, sc_time_stamp(), "Burst:");
    REPORT_TIME(VON, sc_time_stamp(), "  - count: %u", BURST_COUNT);
    REPORT_TIME(VON, sc_time_stamp(), "  - size:  %u", BURST_SIZE);

    REPORT_TIME(VON, sc_time_stamp(), "Scratchpad:");
    REPORT_TIME(VON, sc_time_stamp(), "  - word size (in bytes): %u", size_of_data32_t);
    REPORT_TIME(VON, sc_time_stamp(), "  - banks:                %u", NUM_BANKS);
    REPORT_TIME(VON, sc_time_stamp(), "  - capacity (in bytes):  %u", SCRATCHPAD_CAPACITY);
    REPORT_TIME(VON, sc_time_stamp(), "  - capacity (in words):  %u", SCRATCHPAD_CAPACITY_IN_WORDS);
    REPORT_TIME(VON, sc_time_stamp(), "  - address width:        %u", SCRATCHPAD_ADDR_WIDTH);

    REPORT_TIME(VON, sc_time_stamp(), "Write data");
    for (int i = 0; i < BURST_SIZE * BURST_COUNT; i++) {
        wait();
        REPORT_TIME(VOFF, sc_time_stamp(), "------------------------------------");

        data32_t data = i + 69;

        data_in.Push(data);
        fifo.push_back(data);
        REPORT_TIME(VON, sc_time_stamp(), "data_in = %u", TO_UINT32(data));
    }
    REPORT_TIME(VON, sc_time_stamp(), "Done");
}


void Stimuli::sink() {

    data_out.Reset();

    wait(2, SC_NS);

    for (int i = 0; i < BURST_SIZE * BURST_COUNT; i++) {
        wait();
        REPORT_TIME(VOFF, sc_time_stamp(), "------------------------------------");

        data32_t dut_data = data_out.Pop();

        data32_t ref_data = fifo.front();
        fifo.pop_front();

        REPORT_TIME(VON, sc_time_stamp(), "data_out = %u", TO_UINT32(dut_data));

        if (dut_data != ref_data) {
            REPORT_ERROR(VON, "Mismatch: dut = %u, ref = %u", TO_UINT32(dut_data), TO_UINT32(ref_data));
            REPORT_TIME(VON, sc_time_stamp(), "\t***FAIL***");
            assert(false);
        }
    }

    // Wait for any transactions in the DUT to clear out
    //wait(20, SC_NS);

    REPORT_TIME(VON, sc_time_stamp(), "Terminating simulation");

    sc_stop();
}

