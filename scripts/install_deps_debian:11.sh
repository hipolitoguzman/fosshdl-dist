#!/bin/sh
COMMON_SW="git lcov gcovr gtkwave octave"
COMMON_DEPS="make build-essential g++"
YOSYS_DEPS="tcl tcl-dev clang"
SBY_DEPS="libgmp-dev ninja-build python3-dev curl"
GHDL_DEPS="wget gnat texinfo zlib1g-dev"
COCOTB_DEPS="python3-pip"
ICESTORM_DEPS="libftdi-dev"
NEXTPNR_DEPS="clang-format qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools python3-dev libboost-all-dev libeigen3-dev"
VERILATOR_DEPS="autoconf flex bison libfl2 libfl-dev"
IVERILOG_DEPS="make g++ bison flex gperf libreadline-dev autoconf"

DEBIAN_FRONTEND=noninteractive apt install -y $COMMON_SW $COMMON_DEPS $YOSYS_DEPS $SBY_DEPS $GHDL_DEPS $COCOTB_DEPS $ICESTORM_DEPS $NEXTPNR_DEPS $VERILATOR_DEPS $IVERILOG_DEPS
