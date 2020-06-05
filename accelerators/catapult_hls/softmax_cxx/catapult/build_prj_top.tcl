array set opt {
    # The 'asic' flag enables either ASIC or FPGA targets:
    # = 0 -> Vivado (FPGA)
    # = 1 -> Mentor Design Compiler
    # = 2 -> Cadence Encounter RTL Compiler
    # = 3 -> Cadence Genus
    #
    # The 'csim' flag enables C simulation.
    # The 'hsynth' flag enables HLS.
    # The 'rtlsim' flag enable RTL simulation.
    # The 'lsynth' flag enable logic synthesis.
    # The 'debug' flag stops Catapult HLS before the architect step.
    asic       0
    csim       1
    hsynth     1
    rtlsim     0
    lsynth     0
    debug      0
    hier       1
}

source ./build_prj.tcl
