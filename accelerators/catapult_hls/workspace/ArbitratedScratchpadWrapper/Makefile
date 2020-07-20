MATCHLIB_UNITTESTS_DIR=../../common/matchlib/cmod/unittests
CFLAGS ?= -Wno-unused-label
include $(MATCHLIB_UNITTESTS_DIR)/unittests_Makefile

syn:
	catapult -product ultra -f ./project.tcl
.PHONY: syn

ultraclean: clean
	rm -rf Catapult* *log design_checker*.tcl
.PHONY: ultraclean
