# This path is host dependent.
export CATAPULT_PATH=/tools/Mentor_Graphics/Catapult_Synthesis/10.5a-871028

# Let's use GCC provided with Catapult HLS
export PATH=${CATAPULT_PATH}/Mgc_home/bin:${PATH}

# Makefiles and scripts from Catapult HLS and MatchLib may rely on these
# variables.
export MGC_HOME=${CATAPULT_PATH}
export CATAPULT_HOME=${CATAPULT_PATH}/Mgc_home

# Let's use the SystemC headers and library provided with Catapult HLS.
export SYSTEMC=${CATAPULT_PATH}/Mgc_home/shared
export SYSTEMC_HOME=${SYSTEMC}

# Boost libraries.
export ESP_ROOT=$PWD/../../../..
export BOOST_HOME=$ESP_ROOT/accelerators/catapult_hls/common/boost

# Additional static libraries.
export LIBDIR=-L${CATAPULT_PATH}/Mgc_home/shared/lib $LIBDIR

# Additional dynamic libraries.
export LD_LIBRARY_PATH=${BOOST_HOME}/lib:${LD_LIBRARY_PATH}

# We may need Mentor licenses.
export LM_LICENSE_FILE=${LM_LICENSE_FILE}:1720@bioeecad.ee.columbia.edu

export PS1="[matchlib] $PS1"
