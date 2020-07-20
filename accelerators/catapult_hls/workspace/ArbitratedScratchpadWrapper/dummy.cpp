#include "dummy.h"

#include "utils.h"
#include "config.h"

// Producer process.
void Dummy::producer() {
    // Reset.
    data_in.Reset();
    req_port_01.ResetWrite();
    wait();

    // The producer operates in bursts (BURST_COUNT)
PRODUCER_OUTER_LOOP:
    for (unsigned i = 0; i < BURST_COUNT; i++) {

        // The producer reads BURST_COUNT words from the testbench and writes
        // them to the ASW.
PRODUCER_INNER_LOOP:
        for (unsigned j = 0; j < BURST_SIZE; j++) {
            REPORT_TIME(VOFF, sc_time_stamp(), "Producer has requested data from testbench");
            // Read a data word from the testbench.
            data32_t data = data_in.Pop();
            REPORT_TIME(VOFF, sc_time_stamp(), "Producer has received data from testbench: %u", TO_UINT32(data));

            unsigned addr = (i * BURST_SIZE + j) % SCRATCHPAD_CAPACITY_IN_WORDS;

            // Write a data word to the ASW.
            req_t req;
            req.type.val = CLITYPE_T::STORE;
            req.valids[0] = true;
            req.addr[0] = addr;
            req.data[0] = data;

            req_port_01.Push(req);

            REPORT_TIME(VON, sc_time_stamp(), "Producer has sent data to PLM[%u]: %u", addr, TO_UINT32(data));
        }

        // Sync with the consumer.
        handshake.req();
    }

PRODUCER_DONE:
    while (true) wait();
}

// Consumer process.
void Dummy::consumer() {
    // Reset.
    data_out.Reset();
    req_port_02.ResetWrite();
    resp_port_02.ResetRead();
    wait();


    // The consumer operates in bursts (BURST_COUNT).
CONSUMER_OUTER_LOOP:
    for (unsigned i = 0; i < BURST_COUNT; i++) {

        // Sync with the producer.
        handshake.ack();

        // The consumer reads BURST_COUNT words from the ASW and write them to
        // the testbench.
CONSUMER_INNER_LOOP:
        for (unsigned j = 0; j < BURST_SIZE; j++) {

            unsigned addr = (i * BURST_SIZE + j) % SCRATCHPAD_CAPACITY_IN_WORDS;

            REPORT_TIME(VOFF, sc_time_stamp(), "Comsumer ready to go");

            // Read a data word to the ASW.
            req_t req;
            req.type.val = CLITYPE_T::LOAD;
            req.valids[0] = true;
            req.addr[0] = addr;
            req.data[0] = 0xdeadbeef;

            REPORT_TIME(VOFF, sc_time_stamp(), "Consumer has requested data from PLM");
            req_port_02.Push(req);
            rsp_t resp = resp_port_02.Pop();

            data32_t data = resp.data[0];
            REPORT_TIME(VON, sc_time_stamp(), "Consumer has received data from PLM[%u]: %u", addr, TO_UINT32(data));

            // Write a data word to the testbench.
            data_out.Push(data);
            REPORT_TIME(VOFF, sc_time_stamp(), "Consumer has sent data to testbench: %u", TO_UINT32(data));
        }
    }

CONSUMER_DONE:
    while (true) wait();
}
