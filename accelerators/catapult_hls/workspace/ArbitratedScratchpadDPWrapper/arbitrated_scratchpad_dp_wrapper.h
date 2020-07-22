#ifndef __ARBITRATED_SCRATCHPAD_DP_WRAPPER_H__
#define __ARBITRATED_SCRATCHPAD_DP_WRAPPER_H__

#include "data_types.h"

#define HLS_ALGORITHMICC
#include <ArbitratedScratchpadDP.h>   // MatchLib
#include <connections/connections.h>  // Mentor

#define NUM_BANK_ENTRIES 1024 // in bytes
#define NUM_BANK_WORDS (NUM_BANK_ENTRIES / size_of_data32_t)
#define NUM_BANKS 2
#define NUM_READ_PORTS 2
#define NUM_WRITE_PORTS 2
#define LEN_INPUT_BUFFER 0
#define SCRATCHPAD_CAPACITY (NUM_BANK_ENTRIES * NUM_BANKS) // in bytes
#define SCRATCHPAD_CAPACITY_IN_WORDS (NUM_BANK_WORDS * NUM_BANKS)
#define SCRATCHPAD_ADDR_WIDTH nvhls::nbits<SCRATCHPAD_CAPACITY-1>::val

//typedef cli_req_t<data32_t, SCRATCHPAD_ADDR_WIDTH, 1> req_t;
//typedef cli_rsp_t<data32_t, 1> rsp_t;

typedef NVUINTW(SCRATCHPAD_ADDR_WIDTH) address_t;

#define REQ_LOAD 0
#define REQ_STORE 1

class req_t {
public:
    bool type; // 0 = LOAD, 1 = STORE
    data32_t data;
    address_t addr;
    bool valids;

    static const int width = 1 + 32 + SCRATCHPAD_ADDR_WIDTH + 1;

    template <unsigned int Size>
    void Marshall(Marshaller<Size> &m) {
        m& type;
        m& data;
        m& addr;
        m& valids;
    }

    req_t() : type(0), data(0), addr(0), valids(false) { }

    req_t(const req_t &other) : type(other.type), data(other.data), addr(other.addr), valids(other.valids) { }

    inline req_t &operator=(const req_t &other) {
        type = other.type;
        data = other.data;
        addr = other.addr;
        valids = other.valids;
        return *this;
    }

    inline bool operator==(const req_t &rhs) const {
        return ((rhs.type == type) && (rhs.data == data) && (rhs.addr == addr) && (rhs.valids == valids));
    };

    friend inline ostream &operator<<(ostream &os, req_t const &req) {
        os << "{ type: "
                  << ((req.type == REQ_LOAD) ? "LOAD" : "STORE") << ", "
                  << "data: " << req.data << ", "
                  << "addr: " << req.addr << ", "
                  << "valids: " << req.valids << " }";
        return os;
    }

    friend inline void sc_trace(sc_trace_file *tf, const req_t &req, const std::string &name) {
        std::stringstream sstm_c;
        sstm_c << name << ".data";
        sc_trace(tf, req.data, sstm_c.str());
        sstm_c << name << ".addr";
        sc_trace(tf, req.addr, sstm_c.str());
        sstm_c << name << ".valids";
        sc_trace(tf, req.valids, sstm_c.str());
    }

};

class rsp_t {
public:
    data32_t data;
    bool valids;

    static const int width = 32 + 1;

    template <unsigned int Size>
    void Marshall(Marshaller<Size> &m) {
        m& data;
        m& valids;
    }

    rsp_t() : data(0), valids(false) { }

    rsp_t(const rsp_t &other) : data(other.data), valids(other.valids) { }

    inline rsp_t &operator=(const rsp_t &other) {
        data = other.data;
        valids = other.valids;
        return *this;
    }

    inline bool operator==(const rsp_t &rhs) const {
        return ((rhs.data == data)
                && (rhs.valids == valids));
    };

    friend inline ostream &operator<<(ostream &os, rsp_t const &rsp) {
        os << "{ data:" << rsp.data << ","
              << rsp.valids << "}";
        return os;
    }

    friend inline void sc_trace(sc_trace_file *tf, const rsp_t &rsp, const std::string &name) {
        std::stringstream sstm_c;
        sstm_c << name << ".data";
        sc_trace(tf, rsp.data, sstm_c.str());
        sstm_c << name << ".valids";
        sc_trace(tf, rsp.valids, sstm_c.str());
    }

};


SC_MODULE (ScratchpadWrapper) {

    // Clock and reset ports.
    sc_in_clk clk;
    sc_in <bool> rst;

    // Data req/rsp ports.
    Connections::In<req_t> req_port_01;
    Connections::Out<rsp_t> rsp_port_01;
    Connections::In<req_t> req_port_02;
    Connections::Out<rsp_t> rsp_port_02;

    // Constructor.
    SC_HAS_PROCESS(ScratchpadWrapper);
    ScratchpadWrapper(sc_module_name name):
        sc_module(name),
        clk("clk"),
        rst("rst"),
        req_port_01("req_port_01"),
        rsp_port_01("rsp_port_01"),
        req_port_02("req_port_02"),
        rsp_port_02("rsp_port_02"),
        req_wrapper_01("req_wrapper_01"),
        rsp_wrapper_01("rsp_wrapper_01"),
        req_wrapper_02("req_wrapper_02"),
        rsp_wrapper_02("rsp_wrapper_02")
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
    Connections::Combinational<rsp_t> rsp_wrapper_01;

    Connections::Combinational<req_t> req_wrapper_02;
    Connections::Combinational<rsp_t> rsp_wrapper_02;

    // Memory element(s).
    ArbitratedScratchpadDP<NUM_BANKS, NUM_READ_PORTS, NUM_WRITE_PORTS, NUM_BANK_ENTRIES, data32_t, /* isSF*/ false, /* IsSPRAM*/ false> scratchpad;

    // Processes.
    void wrapper();
    void thread_port_01();
    void thread_port_02();
};

#endif
