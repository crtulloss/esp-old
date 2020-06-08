array set opt {
    # The 'csim' flag enables C simulation.
    # The 'hsynth' flag enables HLS.
    # The 'rtlsim' flag enables RTL simulation.
    # The 'lsynth' flag enables logic synthesis.
    # The 'debug' flag stops Catapult HLS before the architect step.
    plm_bram   1
    plm_shrd   0
    csim       1
    hsynth     1
    rtlsim     0
    lsynth     0
    debug      0
    hier       0
}

source ./build_prj.tcl
