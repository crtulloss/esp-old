array set opt {
    # The 'asic' flag enables either ASIC or FPGA targets:
    # = 0 -> Vivado (FPGA)
    # = 1 -> Mentor Design Compiler
    # = 2 -> Cadence Encounter RTL Compiler
    # = 3 -> Cadence Genus
    # the 'channels' flag enable Catapult HLS communication channels:
    # = 0 -> p2p
    # = 1 -> Connections
    asic       0
    channels   1
    csim       1
    hsynth     1
    rtlsim     1
    lsynth     0
}

source ./build_prj.tcl
