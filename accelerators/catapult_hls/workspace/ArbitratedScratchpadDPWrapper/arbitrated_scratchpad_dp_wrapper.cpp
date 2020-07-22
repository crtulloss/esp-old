#include "arbitrated_scratchpad_dp_wrapper.h"

#include "utils.h"

void ScratchpadWrapper::wrapper() {
    //scratchpad.clear();
    req_wrapper_01.ResetRead();
    req_wrapper_02.ResetRead();
    rsp_wrapper_01.ResetWrite();
    rsp_wrapper_02.ResetWrite();

#if 0

    cli_req_t<data32_t, SCRATCHPAD_ADDR_WIDTH, NUM_INPUTS> bundle_req;
    cli_rsp_t<data32_t, NUM_INPUTS> bundle_rsp;

    req_t stored_req;
    bool  stored_req_valid = false;
#endif

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
    while (true) {

        wait();

        // Check for requests from each of the ports.
        req_t req_from_port_01;
        bool got_req_01 __attribute__((unused));
        got_req_01 = req_wrapper_01.PopNB(req_from_port_01);
        //if (!got_req_01) req_from_port_01.valids[0] = false;
        //if (got_req_01)
        //    REPORT_TIME(VON, sc_time_stamp(),
        //            "req_from_port_01: %u, type: %u, data: %u (%X), addr: %u, valids: %u",
        //            got_req_01, req_from_port_01.type, TO_UINT32(req_from_port_01.data),
        //            TO_UINT32(req_from_port_01.data), TO_UINT32(req_from_port_01.addr), req_from_port_01.valids);

        req_t req_from_port_02;
        bool got_req_02 __attribute__((unused));
        got_req_02 = req_wrapper_02.PopNB(req_from_port_02);
        //if (!got_req_02) req_from_port_02.valids[0] = false;
        //if (got_req_02)
        //    REPORT_TIME(VON, sc_time_stamp(),
        //            "req_from_port_02: %u, type: %u, data: %u (%X), addr: %u, valids: %u",
        //            got_req_02, req_from_port_02.type, TO_UINT32(req_from_port_02.data),
        //            TO_UINT32(req_from_port_02.data), TO_UINT32(req_from_port_02.addr), req_from_port_02.valids);

        address_t read_address[NUM_READ_PORTS];
        bool read_req_valid[NUM_READ_PORTS];
        address_t write_address[NUM_WRITE_PORTS];
        bool write_req_valid[NUM_WRITE_PORTS];
        data32_t write_data[NUM_WRITE_PORTS];
        bool read_ack[NUM_READ_PORTS];
        bool write_ack[NUM_WRITE_PORTS];
        bool read_ready[NUM_READ_PORTS];
        data32_t port_read_out[NUM_READ_PORTS];
        bool port_read_out_valid[NUM_READ_PORTS];
        bool complete = false;

#pragma hls_unroll yes
        for (unsigned i = 0; i < NUM_READ_PORTS; i++) {
            read_req_valid[i] = false;
        }

#pragma hls_unroll yes
        for (unsigned i = 0; i < NUM_WRITE_PORTS; i++) {
            write_req_valid[i] = false;
        }

        if (req_from_port_01.valids) {
            if (req_from_port_01.type == REQ_LOAD) {
                read_address[0] = req_from_port_01.addr;
                read_req_valid[0] = true;
            } else {
                write_address[0] = req_from_port_01.addr;
                write_data[0] = req_from_port_01.data;
                write_req_valid[0] = true;
            }
        }

        if (req_from_port_02.valids) {
            if (req_from_port_02.type == REQ_LOAD) {
                read_address[1] = req_from_port_02.addr;
                read_req_valid[1] = true;
            } else {
                write_address[1] = req_from_port_02.addr;
                write_data[1] = req_from_port_02.data;
                write_req_valid[1] = true;
            }
        }

        //REPORT_TIME(VON, sc_time_stamp(),
        //        "read_address: %u %u, read_req_valid: %u %u, write_address: %u %u, write_req_valid: %u %u, write_data: %u %u, read_ack: %u %u, write_ack: %u %u, read_ready: %u %u, port_read_out: %u %u, port_read_out_valid: %u %u",
        //            TO_UINT32(read_address[0]), TO_UINT32(read_address[1]),
        //            read_req_valid[0], read_req_valid[1],
        //            TO_UINT32(write_address[0]), TO_UINT32(write_address[1]),
        //            write_req_valid[0], write_req_valid[1],
        //            TO_UINT32(write_data[0]), TO_UINT32(write_data[1]),
        //            read_ack[0], read_ack[1],
        //            write_ack[0], write_ack[1],
        //            read_ready[0], read_ready[1],
        //            TO_UINT32(port_read_out[0]), TO_UINT32(port_read_out[1]),
        //            port_read_out_valid[0], port_read_out_valid[1]);

        while (!complete) {
            scratchpad.run(read_address, read_req_valid, write_address, write_req_valid, write_data, read_ack, write_ack, read_ready, port_read_out, port_read_out_valid);

            complete = true;

            for(unsigned i = 0; i < NUM_WRITE_PORTS; i++) {
                if (write_req_valid[i]) {
                    if(!write_ack[i]) {
                        complete = false;
                    } else {
                        write_req_valid[i] = false;
                    }
                }
            }

            for(unsigned i = 0; i < NUM_READ_PORTS; i++) {
                if (read_req_valid[i]) {
                    if(!read_ack[i]) {
                        complete = false;
                    } else {
                        read_req_valid[i] = false;
                    }
                }
            }
        }

        if (port_read_out_valid[0]) {
            rsp_t rsp_to_port_01;
            rsp_to_port_01.data = port_read_out[0];
            rsp_to_port_01.valids = true;
            rsp_wrapper_01.Push(rsp_to_port_01);
        }

        if (port_read_out_valid[1]) {
            rsp_t rsp_to_port_02;
            rsp_to_port_02.data = port_read_out[1];
            rsp_to_port_02.valids = true;
            rsp_wrapper_02.Push(rsp_to_port_02);
        }
    }

};

void ScratchpadWrapper::thread_port_01() {
    req_port_01.Reset();
    rsp_port_01.Reset();
    req_wrapper_01.ResetWrite();
    rsp_wrapper_01.ResetRead();

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
    while (true) {
        req_t cur_req = req_port_01.Pop();
        req_wrapper_01.Push(cur_req);

        if (cur_req.type == REQ_LOAD) {
            rsp_port_01.Push(rsp_wrapper_01.Pop());
        }
    }
}

void ScratchpadWrapper::thread_port_02() {
    req_port_02.Reset();
    rsp_port_02.Reset();
    req_wrapper_02.ResetWrite();
    rsp_wrapper_02.ResetRead();

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
    while (true) {
        req_t cur_req = req_port_02.Pop();
        req_wrapper_02.Push(cur_req);

        if (cur_req.type == REQ_LOAD) {
            rsp_port_02.Push(rsp_wrapper_02.Pop());
        }
    }
}

