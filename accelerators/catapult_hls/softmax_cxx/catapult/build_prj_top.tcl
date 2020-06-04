array set opt {
    # The 'asic' flag enables either ASIC or FPGA targets:
    # = 0 -> Vivado (FPGA)
    # = 1 -> Mentor Design Compiler
    # = 2 -> Cadence Encounter RTL Compiler
    # = 3 -> Cadence Genus
    #
    # The 'channels' flag enables Catapult HLS communication channels:
    # = 0 -> Legacy P2P
    # = 1 -> MatchLib Connections
    #
    # The 'plm_bram' flag enable BRAMs (SRAMs):
    # = 0 -> registers
    # = 1 -> BRAMs/SRAMs
    #
    # The 'plm_shrd' flag enable ac_shared:
    # = 0 -> ac_channel
    # = 1 -> ac_shared
    #
    # The 'csim' flag enables C simulation.
    # The 'hsynth' flag enables HLS.
    # The 'rtlsim' flag enable RTL simulation.
    # The 'lsynth' flag enable logic synthesis.
    # The 'debug' flag stops Catapult HLS before the architect step.
    asic       0
    channels   1
    plm_bram   1
    plm_shrd   0
    csim       1
    hsynth     1
    rtlsim     0
    lsynth     0
    debug      1
}

source ./build_prj.tcl
