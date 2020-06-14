// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "system.hpp"

#include <mc_scverify.h>
#include <mc_connections.h>

#define RESET_PERIOD (30 * CLOCK_PERIOD)

system_t * testbench = NULL;

int sc_main(int argc, char *argv[]) {
	// Kills a Warning when using SC_CTHREADS
	sc_report_handler::set_actions("/IEEE_Std_1666/deprecated", SC_DO_NOTHING);
	sc_report_handler::set_actions (SC_WARNING, SC_DO_NOTHING);

    sc_trace_file* trace_file_ptr = sc_create_vcd_trace_file("trace");

	testbench = new system_t("testbench");

    channel_logs logs;
    logs.enable("log_dir");
    logs.log_hierarchy(*testbench);

	sc_clock        clk("clk", CLOCK_PERIOD, SC_PS);
	sc_signal<bool> rst("rst");

#if defined(__MATCHLIB_CONNECTIONS__)
    //Connections::set_sim_clk(&clk);
#endif

	testbench->clk(clk);
	testbench->rst(rst);
	rst.write(false);

	sc_start(RESET_PERIOD, SC_PS);

	rst.write(true);

    trace_hierarchy(testbench, trace_file_ptr);

    sc_start();

    delete(testbench);

	return 0;
}
