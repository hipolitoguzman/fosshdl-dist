#!/bin/sh
COMMON_SW="git vim emacs lcov gtkwave octave"
COMMON_DEPS="make build-essential g++"
GHDL_DEPS="gnat texinfo zlib1g-dev"
COCOTB_DEPS="python3-pip"
ICESTORM_DEPS="libftdi-dev"
NEXTPNR_DEPS="cmake clang-format qt5-default python3-dev libboost-all-dev libeigen3-dev"
VERILATOR_DEPS="autoconf flex bison libfl2 libfl-dev"
IVERILOG_DEPS="make g++ bison flex gperf libreadline-dev autoconf"

sudo apt install $COMMON_SW $COMMON_DEPS $GHDL_DEPS $COCOTB_DEPS $ICESTORM_DEPS $NEXTPNR_DEPS $VERILATOR_DEPS $IVERILOG_DEPS
