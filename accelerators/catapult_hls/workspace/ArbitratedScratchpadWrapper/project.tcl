
source ../../../hls/run_hls_global_setup.tcl
solution options set /Flows/SCVerify/USE_VCS false
solution options set /Flows/SCVerify/USE_MSIM true

options set Input/SearchPath ". ../../include ../../../../boost/include"
options set Input/CppStandard c++11
solution options set /Output/GenerateCycleNetlist true

#global variables across all steps
set TOP_NAME "Dummy"
set CLK_NAME clk
set CLK_PERIOD 2
set SRC_DIR "./"

set DESIGN_FILES [list dummy.cpp  scratchpad_wrapper.cpp]
set TB_FILES [list main.cpp stimuli.cpp  testbench.cpp]

solution options set Input/TargetPlatform x86_64

# Add your design here
foreach design_file $DESIGN_FILES {
	solution file add $design_file -type SYSTEMC
}
foreach tb_file $TB_FILES {
	solution file add $tb_file -type SYSTEMC -exclude true
}
options set Input/CompilerFlags "-DSC_INCLUDE_DYNAMIC_PROCESSES -DCONNECTIONS_ACCURATE_SIM -DCATAPULT_COMPILE -DHLS_CATAPULT"
go analyze
solution library add mgc_sample-065nm-dw_beh_dc -- -rtlsyntool DesignCompiler -vendor Sample -technology 065nm -Designware Yes
solution library add ram_sample-065nm-singleport_beh_dc

directive set GATE_REGISTERS false

# Clock, interface constrain
set CLK_PERIODby2 [expr $CLK_PERIOD/2]
directive set -CLOCKS "$CLK_NAME \"-CLOCK_PERIOD $CLK_PERIOD -CLOCK_EDGE rising -CLOCK_UNCERTAINTY 0.0 -CLOCK_HIGH_TIME $CLK_PERIODby2 -RESET_SYNC_NAME rst -RESET_ASYNC_NAME arst_n -RESET_KIND sync -RESET_SYNC_ACTIVE high -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high\"    "
directive set -CLOCK_NAME $CLK_NAME

directive set -DESIGN_HIERARCHY "$TOP_NAME"
go compile
go libraries
go assembly

# directive set /$TOP_NAME/master_process/RWLOOP -PIPELINE_INIT_INTERVAL 1 
# directive set /$TOP_NAME/master_process/RWLOOP -PIPELINE_STALL_MODE flush

go architect
solution netlist -replace post_arch.vhd
go allocate
go schedule
go dpfsm
go extract
# go switching
project save

# exit
