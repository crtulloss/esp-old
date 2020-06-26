CXXFLAGS += -std=c++11

#CXXFLAGS += -DHIERARCHICAL_BLOCKS
#SRCS += $(foreach s, $(wildcard ../src/hier/*.cpp), $(shell basename $(s)))
#VPATH += ../src/hier

SRCS += $(foreach s, $(wildcard ../src/basic/*.cpp), $(shell basename $(s)))
VPATH += ../src/basic

include ../../common/systemc.mk
