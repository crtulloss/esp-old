if {$opt(asic) > 0} {
    project new -name Catapult_asic
    set CSIM_RESULTS "./tb_data/catapult_asic_csim_results.log"
    set RTL_COSIM_RESULTS "./tb_data/catapult_asic_rtl_cosim_results.log"
} else {
    project new -name Catapult_fpga
    set CSIM_RESULTS "./tb_data/catapult_fpga_csim_results.log"
    set RTL_COSIM_RESULTS "./tb_data/catapult_fpga_rtl_cosim_results.log"
}

#
# Reset the options to the factory defaults
#

solution new -state initial
solution options defaults

solution options set Flows/ModelSim/VLOG_OPTS {-suppress 12110}
solution options set Flows/ModelSim/VSIM_OPTS {-t ps -suppress 12110}
solution options set Flows/DesignCompiler/OutNetlistFormat verilog
solution options set /Input/CppStandard c++11
#solution options set /Input/TargetPlatform x86_64

solution options set Cache/UserCacheHome "catapult_105c_cache"
#solution options set Cache/UserCacheHome "catapul_105beta_cache"
solution options set Cache/DefaultCacheHomeEnabled false

flow package require /SCVerify
#options set Flows/OSCI/GCOV true
#flow package require /CCOV
#flow package require /SLEC
#flow package require /CDesignChecker

#directive set -DESIGN_GOAL area
##directive set -OLD_SCHED false
#directive set -SPECULATE true
#directive set -MERGEABLE true
directive set -REGISTER_THRESHOLD 8192
#directive set -MEM_MAP_THRESHOLD 32
#directive set -LOGIC_OPT false
#directive set -FSM_ENCODING none
#directive set -FSM_BINARY_ENCODING_THRESHOLD 64
#directive set -REG_MAX_FANOUT 0
#directive set -NO_X_ASSIGNMENTS true
#directive set -SAFE_FSM false
#directive set -REGISTER_SHARING_MAX_WIDTH_DIFFERENCE 8
#directive set -REGISTER_SHARING_LIMIT 0
#directive set -ASSIGN_OVERHEAD 0
#directive set -TIMING_CHECKS true
#directive set -MUXPATH true
#directive set -REALLOC true
#directive set -UNROLL no
#directive set -IO_MODE super
#directive set -CHAN_IO_PROTOCOL standard
#directive set -ARRAY_SIZE 1024
#directive set -REGISTER_IDLE_SIGNAL false
#directive set -IDLE_SIGNAL {}
#directive set -STALL_FLAG false
directive set -TRANSACTION_DONE_SIGNAL true
#directive set -DONE_FLAG {}
#directive set -READY_FLAG {}
#directive set -START_FLAG {}
#directive set -BLOCK_SYNC none
#directive set -TRANSACTION_SYNC ready
#directive set -DATA_SYNC none
#directive set -CLOCKS {clk {-CLOCK_PERIOD 0.0 -CLOCK_EDGE rising -CLOCK_UNCERTAINTY 0.0 -RESET_SYNC_NAME rst -RESET_ASYNC_NAME arst_n -RESET_KIND sync -RESET_SYNC_ACTIVE high -RESET_ASYNC_ACTIVE low -ENABLE_ACTIVE high}}
#directive set -RESET_CLEARS_ALL_REGS true
#directive set -CLOCK_OVERHEAD 20.000000
#directive set -OPT_CONST_MULTS use_library
#directive set -CHARACTERIZE_ROM false
#directive set -PROTOTYPE_ROM true
#directive set -ROM_THRESHOLD 64
#directive set -CLUSTER_ADDTREE_IN_COUNT_THRESHOLD 0
#directive set -CLUSTER_OPT_CONSTANT_INPUTS true
#directive set -CLUSTER_RTL_SYN false
#directive set -CLUSTER_FAST_MODE false
#directive set -CLUSTER_TYPE combinational
#directive set -COMPGRADE fast

#set CLOCK_PERIOD 25

# Design specific options.
if {$opt(asic) > 0} {
solution options set Flows/QuestaSIM/SCCOM_OPTS {-g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -DDMA_WIDTH=64 -DCLOCK_PERIOD=25000}
} else {
solution options set Flows/QuestaSIM/SCCOM_OPTS {-g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -DDMA_WIDTH=64 -DCLOCK_PERIOD=25000}
}

if {$opt(channels) == 0} {
solution options set /Input/CompilerFlags {-DDMA_WIDTH=64 -DCLOCK_PERIOD=25000}
} else {
solution options set /Input/CompilerFlags {-DDMA_WIDTH=64 -DHLS_CATAPULT -D__MNTR_CONNECTIONS__ -DCLOCK_PERIOD=25000}
}

solution options set /Input/SearchPath { \
    ../src \
    ../tb \
    ../../common/syn-templates \
    ../../common/syn-templates/core \
    ../../common/syn-templates/core/accelerators \
    ../../common/syn-templates/core/systems \
    ../../common/syn-templates/utils \
    ../../common/syn-templates/utils/configs }

# Add source files.
solution file add ../src/dummy.cpp -type C++
solution file add ../tb/sc_main.cpp -type C++ -exclude true
solution file add ../tb/system.cpp -type C++ -exclude true

#solution file set ../tb/sc_main.cpp -args {-DDISABLE_PRINTF}

go new

#
#
#

go analyze

#
#
#


# Set the top module and inline all of the other functions.

# 10.4c
#directive set -DESIGN_HIERARCHY dummy

# 10.5
solution design set dummy -top

#
#
#

go compile

# Run C simulation.
if {$opt(csim)} {
    flow run /SCVerify/launch_make ./scverify/Verify_orig_cxx_osci.mk {} SIMTOOL=osci sim
}

#
#
#

# Run HLS.
if {$opt(hsynth)} {

    if {$opt(asic) == 1} {
        solution library add nangate-45nm_beh -- -rtlsyntool DesignCompiler -vendor Nangate -technology 045nm
        solution library add ccs_sample_mem
    } elseif {$opt(asic) == 2} {
        solution library add nangate-45nm_beh -- -rtlsyntool RTLCompiler -vendor Nangate -technology 045nm
        solution library add ccs_sample_mem
    } elseif {$opt(asic) == 3} {
        puts "ERROR: Cadence Genus is not supported"
        exit 1
    } else {
        
        
        solution library add mgc_Xilinx-VIRTEX-uplus-2_beh -- -rtlsyntool Vivado -manufacturer Xilinx -family VIRTEX-uplus -speed -2 -part xcvu9p-flga2104-2-e
        #solution library add mgc_Xilinx-VIRTEX-u-2_beh -- -rtlsyntool Vivado -manufacturer Xilinx -family VIRTEX-u -speed -2 -part xcvu440-flga2892-2-e
        #solution library add mgc_Xilinx-VIRTEX-7-2_beh -- -rtlsyntool Vivado -manufacturer Xilinx -family VIRTEX-7 -speed -2 -part xc7v2000tflg1925-2


        solution library add Xilinx_RAMS
        solution library add Xilinx_ROMS
        solution library add Xilinx_FIFO
    }

    go libraries

    #
    #
    #

    directive set -CLOCKS { \
        clk { \
            -CLOCK_PERIOD 25 \
            -CLOCK_HIGH_TIME 12.5 \
            -CLOCK_OFFSET 0.000000 \
            -CLOCK_UNCERTAINTY 0.0 \
        } \
    }

    # BUGFIX: This prevents the creation of the empty module CGHpart. In the
    # next releases of Catapult HLS, this may be fixed.
    directive set /dummy -GATE_EFFORT normal

    go assembly

    #
    #
    #

    # Top-Module I/O

    # Arrays

    directive set /dummy/dummy:load_input/plm0:cns -MAP_TO_MODULE ccs_ioport.ccs_out_wait
    directive set /dummy/dummy:load_input/plm0:cns -PACKING_MODE sidebyside
    directive set /dummy/dummy:load_input/plm0 -WORD_WIDTH 32768

    directive set /dummy/dummy:load_input/plm1:cns -MAP_TO_MODULE mgc_ioport.mgc_out_stdreg_wait
    directive set /dummy/dummy:load_input/plm1:cns -PACKING_MODE sidebyside
    directive set /dummy/dummy:load_input/plm1 -WORD_WIDTH 32768

    directive set /dummy/dummy:store_output/plm0:cns -MAP_TO_MODULE ccs_ioport.ccs_in_wait
    directive set /dummy/dummy:store_output/plm0:cns -PACKING_MODE sidebyside
    directive set /dummy/dummy:store_output/plm0 -WORD_WIDTH 32768

    directive set /dummy/dummy:store_output/plm1:cns -MAP_TO_MODULE mgc_ioport.mgc_chan_in
    directive set /dummy/dummy:store_output/plm1:cns -PACKING_MODE sidebyside
    directive set /dummy/dummy:store_output/plm1 -WORD_WIDTH 32768

    directive set /dummy/plm0:cns -MAP_TO_MODULE ccs_ioport.ccs_pipe
    directive set /dummy/plm0:cns -PACKING_MODE sidebyside
    directive set /dummy/plm0 -WORD_WIDTH 32768

    directive set /dummy/plm1:cns -MAP_TO_MODULE mgc_ioport.mgc_pipe
    directive set /dummy/plm1:cns -PACKING_MODE sidebyside
    directive set /dummy/plm1 -WORD_WIDTH 32768

    # Loops
   
    directive set /dummy/dummy:load_input/load_input/LOAD_INPUT_TOKENS_LOOP -PIPELINE_INIT_INTERVAL 1 
    directive set /dummy/dummy:store_output/store_output/STORE_OUTPUT_TOKENS_LOOP -PIPELINE_INIT_INTERVAL 1

    go architect

    #
    #
    #

    go allocate

    #
    # RTL
    #

    go extract

    #
    #
    #

    if {$opt(rtlsim)} {
        flow run /SCVerify/launch_make ./scverify/Verify_rtl_v_msim.mk {} SIMTOOL=msim sim
        #flow run /SCVerify/launch_make ./scverify/Verify_rtl_v_msim.mk {} SIMTOOL=msim simgui
    }

    if {$opt(lsynth)} {

        if {$opt(asic) == 1} {
            flow run /DesignCompiler/dc_shell ./concat_rtl.v.dc v
        } elseif {$opt(asic) == 2} {
            flow run /RTLCompiler/rc ./concat_rtl.v.rc v
        } elseif {$opt(asic) == 3} {
            puts "ERROR: Cadence Genus is not supported"
            exit 1
        } else {
            flow run /Vivado/synthesize -shell vivado_concat_v/concat_rtl.v.xv
        }

    }
}

project save
