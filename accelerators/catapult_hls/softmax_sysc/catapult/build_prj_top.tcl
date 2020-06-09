array set opt {
    # The 'csim' flag enables C simulation.
    # The 'hsynth' flag enables HLS.
    # The 'rtlsim' flag enables RTL simulation.
    # The 'lsynth' flag enables logic synthesis.
    # The 'debug' flag stops Catapult HLS before the architect step.
    # The 'uarch' flag selects a micro-architecture:
    #   - 0: Single process
    #   - 1: Four processes with shared memories via MatchLib
    #   - 2: Four processes with shared memories via ac_channels [EXPERIMENTAL]
    plm_bram   1
    plm_shrd   0
    csim       1
    hsynth     1
    rtlsim     0
    lsynth     0
    debug      0
    uarch      2
}

source ./build_prj.tcl
