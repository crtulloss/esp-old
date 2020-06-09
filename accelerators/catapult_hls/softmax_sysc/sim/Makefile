CXXFLAGS += -std=c++11

CXXFLAGS += -DHIERARCHICAL_BLOCKS
SRCS += $(foreach s, $(wildcard ../src/acchannel/*.cpp), $(shell basename $(s)))
VPATH += ../src/acchannel

#SRCS += $(foreach s, $(wildcard ../src/basic/*.cpp), $(shell basename $(s)))
#VPATH += ../src/basic

include ../../common/systemc.mk
