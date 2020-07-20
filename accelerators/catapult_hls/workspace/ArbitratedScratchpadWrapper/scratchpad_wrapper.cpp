#include <scratchpad_wrapper.h>

#include "utils.h"

void ScratchpadWrapper::wrapper() {
    scratchpad.reset();
    req_wrapper_01.ResetRead();
    req_wrapper_02.ResetRead();
    resp_wrapper_01.ResetWrite();
    resp_wrapper_02.ResetWrite();


    cli_req_t<data32_t, SCRATCHPAD_ADDR_WIDTH, NUM_INPUTS> bundle_req;
    cli_rsp_t<data32_t, NUM_INPUTS> bundle_resp;

    req_t stored_req;
    bool  stored_req_valid = false;

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
    while (true) {
        wait();

        // There is a case to be handled. What if req from thread#1 is RD and
        // from Thread#2 is WR??  That's way we have a stored request, in such
        // case the request from Thread#2 gets stored and gets served in the
        // next iteration with higher priority Probably using ArbScratchDP
        // would make that easier.

        // If there is something stored add it to the bundle, do that first.
        if (stored_req_valid) {
            bundle_req.type = stored_req.type;
            bundle_req.valids[1] = stored_req.valids[0];
            bundle_req.addr[1] = stored_req.addr[0];
            bundle_req.data[1] = stored_req.data[0];

            stored_req_valid = false;
        } else {

            // Check for requests from each of the ports.
            req_t req_from_port_01;
            bool got_req_01 = req_wrapper_01.PopNB(req_from_port_01);
            if (!got_req_01) req_from_port_01.valids[0] = false;


            req_t req_from_port_02;
            bool got_req_02 = req_wrapper_02.PopNB(req_from_port_02);
            if (!got_req_02) req_from_port_02.valids[0] = false;

            // Bundle the requests for the ArbitratedScratchpad. They get
            // served in parallel.
            bundle_req.type = got_req_01 ? req_from_port_01.type : req_from_port_02.type;
            bundle_req.valids[0] = req_from_port_01.valids[0];
            bundle_req.addr[0] = req_from_port_01.addr[0];
            bundle_req.data[0] = req_from_port_01.data[0];

            bundle_req.valids[1] = req_from_port_02.valids[0];
            bundle_req.addr[1] = req_from_port_02.addr[0];
            bundle_req.data[1] = req_from_port_02.data[0];

            // If there is a request from port #01 and the type of the request
            // from port #02 is different from the type in #01, store request
            // #02.
            if (got_req_01 && !(req_from_port_01.type == req_from_port_02.type)) {
                bundle_req.valids[1] = false;

                stored_req_valid = true;
                stored_req.type = req_from_port_02.type;
                stored_req.valids[0] = req_from_port_02.valids[0];
                stored_req.addr[0] = req_from_port_02.addr[0];
                stored_req.data[0] = req_from_port_02.data[0];
            }
        }

        // Micromanaging of request specifics
        bool is_load = (bundle_req.type.val == CLITYPE_T::LOAD);
        bool is_request = false;

#pragma hls_unroll yes
        for(int i=0; i<2; ++i) is_request |= bundle_req.valids[i];
#pragma hls_unroll yes
        for(int i=0; i<2; ++i) bundle_resp.valids[i] = false;

        // Iterate until all of the requests in the bundle get served.
        // (Worst case N iterations for N input requests)
        while (is_request) { // While there is at least one request
            cli_rsp_t<data32_t, NUM_INPUTS> scratch_resp;
            bool served[2];

            // run the core function
            scratchpad.load_store(bundle_req, scratch_resp, served);

            // Check if any request has remained.
            is_request = false;
#pragma hls_unroll yes
            for (int i = 0; i < 2; ++i) {
                // mask the current requests depending the served ones.
                bool new_valid = (bundle_req.valids[i] ^ served[i]);
                is_request |= new_valid;
                bundle_req.valids[i] = new_valid;

                // Build the response (only in case of a LOAD request).
                if (is_load && served[i]) {
                    bundle_resp.valids[i] = scratch_resp.valids[i];
                    bundle_resp.data[i] = scratch_resp.data[i];
                    NVHLS_ASSERT(served[i] && bundle_resp.valids[i]);
                }
            }
        }

        // All requests have been served, thus send responses back to each
        // port (only if it is a LOAD request).
        if (is_load && bundle_resp.valids[0]) {
            rsp_t rsp_thread_one;
            rsp_thread_one.valids[0] = bundle_resp.valids[0];
            rsp_thread_one.data[0] = bundle_resp.data[0];
            resp_wrapper_01.Push(rsp_thread_one);
        }

        if (is_load && bundle_resp.valids[1]) {
            rsp_t rsp_thread_two;
            rsp_thread_two.valids[0] = bundle_resp.valids[1];
            rsp_thread_two.data[0] = bundle_resp.data[1];
            resp_wrapper_02.Push(rsp_thread_two);
        }
    }

};

void ScratchpadWrapper::thread_port_01() {
    req_port_01.Reset();
    resp_port_01.Reset();
    req_wrapper_01.ResetWrite();
    resp_wrapper_01.ResetRead();


#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
    while (true) {
        req_t cur_req = req_port_01.Pop();
        req_wrapper_01.Push(cur_req);

        if (cur_req.type.val == CLITYPE_T::LOAD) {
            resp_port_01.Push(resp_wrapper_01.Pop());
        }
    }
}

void ScratchpadWrapper::thread_port_02() {
    req_port_02.Reset();
    resp_port_02.Reset();
    req_wrapper_02.ResetWrite();
    resp_wrapper_02.ResetRead();

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
    while (true) {
        req_t cur_req = req_port_02.Pop();
        req_wrapper_02.Push(cur_req);

        if (cur_req.type.val == CLITYPE_T::LOAD) {
            resp_port_02.Push(resp_wrapper_02.Pop());
        }
    }
}

