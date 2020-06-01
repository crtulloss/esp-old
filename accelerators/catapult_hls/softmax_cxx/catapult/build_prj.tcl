#
# Accelerator
#

set ACCELERATOR "softmax_cxx"
set PLM_HEIGHT 128
set PLM_WIDTH 32
set PLM_SIZE [expr ${PLM_WIDTH}*${PLM_HEIGHT}]

set DMA_WIDTH ${PLM_WIDTH}

#
# Technology-dependend reports and project dirs.
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

solution options set Flows/ModelSim/VLOG_OPTS {-suppress 12110}
solution options set Flows/ModelSim/VSIM_OPTS {-t ps -suppress 12110}
solution options set Flows/DesignCompiler/OutNetlistFormat verilog
solution options set /Input/CppStandard c++11
#solution options set /Input/TargetPlatform x86_64

set CATAPULT_VERSION  [string map { / - } [string map { . - } [application get /SYSTEM/RELEASE_VERSION]]]
solution options set Cache/UserCacheHome "catapult_cache_$CATAPULT_VERSION"
solution options set Cache/DefaultCacheHomeEnabled false
solution options set /Flows/SCVerify/DISABLE_EMPTY_INPUTS true

flow package require /SCVerify

flow package option set /SCVerify/USE_CCS_BLOCK true
flow package option set /SCVerify/USE_QUESTASIM true
flow package option set /SCVerify/USE_NCSIM false

directive set -REGISTER_THRESHOLD 8192
directive set -RESET_CLEARS_ALL_REGS true

# Flag to indicate SCVerify readiness
set can_simulate 1

# Design specific options.

#
# Flags
#

if {$opt(asic) > 0} {
    solution options set Flows/QuestaSIM/SCCOM_OPTS {-g -x /usr/bin/g++-5 -Wall -Wno-unused-label -Wno-unknown-pragmas -DCLOCK_PERIOD=12500}
} else {
    solution options set Flows/QuestaSIM/SCCOM_OPTS {-64 -g -x c++ -Wall -Wno-unused-label -Wno-unknown-pragmas -DCLOCK_PERIOD=12500}
}

#
# Input
#

solution options set /Input/SearchPath { \
    ../src \
    ../tb \
    ../common }

# Add source files.
solution file add ../src/softmax.cpp -type C++
solution file add ../tb/main.cpp -type C++ -exclude true

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
solution design set $ACCELERATOR -top

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

        # For Catapult 10.5: disable all sequential clock-gating
        directive set GATE_REGISTERS false
    }

    go libraries

    #
    #
    #

    directive set -CLOCKS { \
        clk { \
            -CLOCK_PERIOD 6.4 \
            -CLOCK_EDGE rising \
            -CLOCK_HIGH_TIME 3.2 \
            -CLOCK_OFFSET 0.000000 \
            -CLOCK_UNCERTAINTY 0.0 \
            -RESET_KIND sync \
            -RESET_SYNC_NAME rst \
            -RESET_SYNC_ACTIVE low \
            -RESET_ASYNC_NAME arst_n \
            -RESET_ASYNC_ACTIVE low \
            -ENABLE_NAME {} \
            -ENABLE_ACTIVE high \
        } \
    }

    # BUGFIX: This prevents the creation of the empty module CGHpart. In the
    # next releases of Catapult HLS, this may be fixed.
    directive set /$ACCELERATOR -GATE_EFFORT normal

    # Add ESP accelerator done signal
    ###directive set /$ACCELERATOR/store -DONE_FLAG acc_done
    directive set /$ACCELERATOR -DONE_FLAG acc_done

    go assembly

    #
    #
    #

    # Top-Module I/O
    directive set /$ACCELERATOR/debug:rsc -MAP_TO_MODULE ccs_ioport.ccs_out
    
    directive set /$ACCELERATOR/conf_info.batch:rsc -MAP_TO_MODULE ccs_ioport.ccs_in
    directive set /$ACCELERATOR/conf_info.batch:rsc -MAP_TO_MODULE ccs_ioport.ccs_in 
    directive set /$ACCELERATOR/conf_done:rsc -MAP_TO_MODULE ccs_ioport.ccs_in
    
    directive set /$ACCELERATOR/dma_read_ctrl:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait
    directive set /$ACCELERATOR/dma_write_ctrl:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait
    directive set /$ACCELERATOR/dma_read_chnl:rsc -MAP_TO_MODULE ccs_ioport.ccs_in_wait
    directive set /$ACCELERATOR/dma_write_chnl:rsc -MAP_TO_MODULE ccs_ioport.ccs_out_wait

    # Arrays
    directive set /$ACCELERATOR/core/plm_in.data:rsc -MAP_TO_MODULE Xilinx_RAMS.BLOCK_1R1W_RBW
    directive set /$ACCELERATOR/core/plm_out.data:rsc -MAP_TO_MODULE Xilinx_RAMS.BLOCK_1R1W_RBW

    # Loops
    directive set /$ACCELERATOR/core/CONFIG_LOOP -ITERATIONS 1

    directive set /$ACCELERATOR/core/BATCH_LOOP -PIPELINE_INIT_INTERVAL 1
    directive set /$ACCELERATOR/core/BATCH_LOOP -PIPELINE_STALL_MODE flush

    # Loops performance tracing

    # Area vs Latency Goals

    directive set /$ACCELERATOR/core -EFFORT_LEVEL high
    directive set /$ACCELERATOR/core -DESIGN_GOAL Latency

    if {$opt(debug) != 1} {
        go architect

        #
        #
        #

        go allocate

        #
        # RTL
        #

        #directive set ENABLE_PHYSICAL true

        go extract

        #
        #
        #

        if {$opt(rtlsim)} {
            #flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim sim
            flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim simgui
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
}

project save
