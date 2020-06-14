#ifndef __ARBITRATEDSCRATCHPADDP_TOP__
#define __ARBITRATEDSCRATCHPADDP_TOP__

#include <ArbitratedScratchpadDP.h>

#include "softmax_fpdata.hpp"

#ifndef NUM_READ_PORTS
#define NUM_READ_PORTS 2
#endif

#ifndef NUM_WRITE_PORTS
#define NUM_WRITE_PORTS 2
#endif


#ifndef NUM_BANKS
#define NUM_BANKS 2
#endif

#ifndef NUM_ENTRIES_PER_BANK
#define NUM_ENTRIES_PER_BANK 128
#endif

const unsigned int kNumBanks = NUM_BANKS;
const unsigned int kNumReadPorts = NUM_READ_PORTS;
const unsigned int kNumWritePorts = NUM_WRITE_PORTS;
const unsigned int kEntriesPerBank = NUM_ENTRIES_PER_BANK;

const unsigned int kAddressSize = nvhls::index_width<NUM_BANKS * NUM_ENTRIES_PER_BANK>::val;

typedef NVUINTW(kAddressSize) Address;

template <class DATA_TYPE>
void ArbitratedScratchpadDPTop(
        Address read_address[NUM_READ_PORTS],
        bool read_req_valid[NUM_READ_PORTS],
        Address write_address[NUM_WRITE_PORTS],
        bool write_req_valid[NUM_WRITE_PORTS],
        DATA_TYPE write_data[NUM_WRITE_PORTS],
        bool read_ack[NUM_READ_PORTS],
        bool write_ack[NUM_WRITE_PORTS],
        DATA_TYPE port_read_out[NUM_READ_PORTS],
        bool port_read_out_valid[NUM_READ_PORTS]);


template <class DATA_TYPE>
void ArbitratedScratchpadDPTop(
        Address read_address[NUM_READ_PORTS],
        bool read_req_valid[NUM_READ_PORTS],
        Address write_address[NUM_WRITE_PORTS],
        bool write_req_valid[NUM_WRITE_PORTS],
        DATA_TYPE write_data[NUM_WRITE_PORTS],
        bool read_ack[NUM_READ_PORTS],
        bool write_ack[NUM_WRITE_PORTS],
        DATA_TYPE port_read_out[NUM_READ_PORTS],
        bool port_read_out_valid[NUM_READ_PORTS]) {

    typedef ArbitratedScratchpadDP<NUM_BANKS, NUM_READ_PORTS, NUM_WRITE_PORTS, NUM_ENTRIES_PER_BANK, DATA_TYPE> scratchpad_t;

    static scratchpad_t scratchpad_inst;

    bool read_ready[NUM_READ_PORTS];

    scratchpad_inst.run(read_address, read_req_valid, write_address, write_req_valid, write_data, read_ack, write_ack, read_ready, port_read_out, port_read_out_valid);
}

#endif
