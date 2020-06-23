# Usage:
# $ source envsetup.sh
#

export TECH=virtexup

export ESP_ROOT=$PWD/../../../../

export ACCELERATOR=add_accelerator_cxx

export DMA_WIDTH=64

# Base directory for CAD tools.
export CAD_PATH=/opt/cad

# We do not need licensing for this example.
#export LM_LICENSE_FILE=${LM_LICENSE_FILE}:1720@bioeecad.ee.columbia.edu
#export XILINXD_LICENSE_FILE="2177@espdev.cs.columbia.edu"

# This path is host dependent.
export CATAPULT_PATH=${CAD_PATH}/catapult

# Let's use GCC provided with Catapult HLS
export PATH=${CATAPULT_PATH}/bin:${PATH}
export LD_LIBRARY_PATH=${CATAPULT_PATH}/lib/:$LD_LIBRARY_PATH

export MGC_HOME=${CAD_PATH}/catapult

# We do NOT need Mentor Modelsim (simulator) for this example.
#export PATH=${CAD_PATH}/msim/modeltech/bin/:$PATH

# Let's use the SystemC headers and library provided with Catapult HLS.
export SYSTEMC=${CATAPULT_PATH}/shared

export PS1="[catapult-nolicense] $PS1"
