#!/bin/sh
var="foo"
echo $var

COMMON_DEPS="git make g++"
GHDL_DEPS="gnat texinfo zlib1g-dev"
COCOTB_DEPS="python3-pip"
NEXTPNR_DEPS="cmake clang-format qt5-default python3-dev libboost-all-dev libeigen3-dev"
VERILATOR_DEPS="autoconf flex bison libfl2 libfl-dev"

sudo apt install $COMMON_DEPS $GHDL_DEPS $COCOTB_DEPS $NEXTPNR_DEPS $VERILATOR_DEPS
