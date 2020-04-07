#
# Accelerator
#

set ACCELERATOR "fft"
set PLM_HEIGHT [expr 32]
set PLM_WIDTH 64
set PLM_SIZE [expr ${PLM_WIDTH}*${PLM_HEIGHT}]

set DMA_WIDTH ${PLM_WIDTH}

#
# Technology
#

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

solution options set Message/ErrorOverride CIN-188 -remove

solution options set Flows/ModelSim/VLOG_OPTS {-suppress 12110}
solution options set Flows/ModelSim/VSIM_OPTS {-t ps -suppress 12110}
solution options set Flows/DesignCompiler/OutNetlistFormat verilog
solution options set /Input/CppStandard c++11
#solution options set /Input/TargetPlatform x86_64

solution options set Cache/UserCacheHome "catapult_105c_cache"
#solution options set Cache/UserCacheHome "catapul_105beta_cache"
solution options set Cache/DefaultCacheHomeEnabled false

flow package require /SCVerify
flow package option set /SCVerify/USE_QUESTASIM true
flow package option set /SCVerify/USE_NCSIM true

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

#set CLOCK_PERIOD 12.5

# Design specific options.

#
# Flags
#

if {$opt(asic) > 0} {
solution options set Flows/QuestaSIM/SCCOM_OPTS {-g -x /usr/bin/g++-5 -Wall -Wno-unused-label -Wno-unknown-pragmas -DDMA_WITDH=64 -DFX_WIDTH=64 -DFX32_IL=12 -DFX64_IL=42 -DCLOCK_PERIOD=12500}
#solution options set Flows/NCSIM/SCCOM_OPTS {-g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -D=64 -DCLOCK_PERIOD=12500}
} else {
solution options set Flows/QuestaSIM/SCCOM_OPTS {-64 -g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -DDMA_WIDTH=64  -DFX_WIDTH=64 -DFX32_IL=12 -DFX64_IL=42 -DCLOCK_PERIOD=12500}

    #solution options set Flows/QuestaSIM/SCCOM_OPTS {-cpppath /usr/bin/g++-5 -g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -D=64 -DCLOCK_PERIOD=12500}
#solution options set Flows/NCSIM/SCCOM_OPTS {-g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -D=64 -DCLOCK_PERIOD=12500}
}

if {$opt(channels) == 0} {
solution options set /Input/CompilerFlags {-DDMA_WIDTH=64 -DFX_WIDTH=64 -DFX32_IL=12 -DFX64_IL=42 -DCLOCK_PERIOD=12500}
} else {
solution options set /Input/CompilerFlags {-DDMA_WIDTH=64 -DFX_WIDTH=64 -DFX32_IL=12 -DFX64_IL=42 -DHLS_CATAPULT -D__MNTR_CONNECTIONS__ -DCLOCK_PERIOD=12500}
}

#
# Input
#

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
solution file add ../src/fft.cpp -type C++
solution file add ../tb/sc_main.cpp -type C++ -exclude true
solution file add ../tb/system.cpp -type C++ -exclude true
solution file add ../tb/fft_test.cpp -type C++ -exclude true

#solution file set ../tb/sc_main.cpp -args {-DDISABLE_PRINTF}


#
# Output
#

# Verilog only
solution option set Output/OutputVHDL false
solution option set Output/OutputVerilog true

# Package output in Solution dir
solution option set Output/PackageOutput true
solution option set Output/PackageStaticFiles true

# Add Prefix to library and generated sub-blocks
solution option set Output/PrefixStaticFiles true
solution options set Output/SubBlockNamePrefix "esp_acc_${ACCELERATOR}_"

# Do not modify names
solution option set Output/DoNotModifyNames true

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
#directive set -DESIGN_HIERARCHY ${ACCELERATOR}

# 10.5
solution design set ${ACCELERATOR} -top

#directive set PRESERVE_STRUCTS false

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
            -CLOCK_PERIOD 12.5 \
            -CLOCK_HIGH_TIME 6.25 \
            -CLOCK_OFFSET 0.000000 \
            -CLOCK_UNCERTAINTY 0.0 \
        } \
    }

    # BUGFIX: This prevents the creation of the empty module CGHpart. In the
    # next releases of Catapult HLS, this may be fixed.
    directive set /${ACCELERATOR} -GATE_EFFORT normal

    go assembly

    #
    #
    #

    # Top-Module I/O

    # Arrays

    #directive set /${ACCELERATOR}/${ACCELERATOR}:load_input/load_input/LOAD_INPUT_TOKENS_LOOP:plm_local.data:rsc -MAP_TO_MODULE Xilinx_RAMS.BLOCK_1R1W_RBW

    directive set /${ACCELERATOR}/plm_in:cns -MAP_TO_MODULE Xilinx_FIFO.FIFO
    directive set /${ACCELERATOR}/plm_in:cns -PACKING_MODE sidebyside
#    directive set /${ACCELERATOR}/plm_in:cns -STAGE_REPLICATION 0
    directive set /${ACCELERATOR}/plm_in -WORD_WIDTH ${PLM_SIZE}

    directive set /${ACCELERATOR}/plm_out:cns -MAP_TO_MODULE Xilinx_FIFO.FIFO
    directive set /${ACCELERATOR}/plm_out:cns -PACKING_MODE sidebyside
#    directive set /${ACCELERATOR}/plm_out:cns -STAGE_REPLICATION 0
    directive set /${ACCELERATOR}/plm_out -WORD_WIDTH ${PLM_SIZE}

    # Loops

    #directive set /${ACCELERATOR}/${ACCELERATOR}:load_input/load_input/LOAD_INPUT_DATA_LOOP -PIPELINE_INIT_INTERVAL 1
    #directive set /${ACCELERATOR}/${ACCELERATOR}:store_output/store_output/STORE_OUTPUT_DATA_LOOP -PIPELINE_INIT_INTERVAL 1

    # Area vs Latency Goals

    directive set /${ACCELERATOR}/config_accelerator -DESIGN_GOAL latency
    directive set /${ACCELERATOR}/${ACCELERATOR}:load_input/load_input -DESIGN_GOAL latency
    directive set /${ACCELERATOR}/${ACCELERATOR}:compute_kernel/compute_kernel -DESIGN_GOAL latency
    directive set /${ACCELERATOR}/${ACCELERATOR}:store_output/store_output -DESIGN_GOAL latency

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
        flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim sim
        #flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim simgui
    }

    if {$opt(lsynth)} {

        if {$opt(asic) == 1} {
            flow run /DesignCompiler/dc_shell ./concat_${ACCELERATOR}.v.dc v
        } elseif {$opt(asic) == 2} {
            flow run /RTLCompiler/rc ./concat_${ACCELERATOR}.v.rc v
        } elseif {$opt(asic) == 3} {
            puts "ERROR: Cadence Genus is not supported"
            exit 1
        } else {
            flow run /Vivado/synthesize -shell vivado_concat_v/concat_${ACCELERATOR}.v.xv
            #flow run /Vivado/synthesize vivado_concat_v/concat_${ACCELERATOR}.v.xv
        }

    }
}

project save
