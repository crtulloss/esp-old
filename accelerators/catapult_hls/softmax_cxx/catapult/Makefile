# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

syn:
	catapult -product ultra -f ./build_prj_top.tcl &
.PHONY: syn

syn-sh:
	catapult -product ultra -shell -f ./build_prj_top.tcl
.PHONY: syn-sh

clean:
	rm -rf Catapult*
	rm -rf catapult_cache*
	rm -f catapult.pinfo
	rm -f log_dir_data.txt
	rm -f log_dir_names.txt
	rm -f trace.vcd
	rm -f transcript
	rm -f catapult.log
	rm -f vsim_stacktrace.vstf
	rm -f design_checker_constraints.tcl
	rm -f design_checker_pre_build.tcl
.PHONY: clean
