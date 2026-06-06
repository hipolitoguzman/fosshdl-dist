# Where to install
PREFIX = /home/salas/fosshdl

# If your user has write permissions in the install location (such as when
# installing in your $(HOME), you can comment the SUDO definition line below
# and binaries won't be installed by root
#SUDO = sudo

# By default, use all available processors to compile. Change NPROC to a fixed
# number if you want to use less processors
NPROC := $(shell nproc)

# Use a GCC version supported by GHDL (supported versions are listed on
# https://ghdl.readthedocs.io/en/latest/building/gcc/index.html)
# Keep in mind that not all gcc versions can generate code coverage with GHDL
# It seems prudent to use one of the versions that the official ghdl repo uses
# in its github actions, such as 9.3.0 or 12.1.0
GCC_VERSION = 12.1.0

# List of software to compile and install. Comment any one you don't want.
selected += yosys
selected += SymbiYosys
selected += eqy
selected += ghdl
selected += ghdl-yosys-plugin
selected += nvc
#selected += arachne-pnr
selected += nextpnr
selected += icestorm
selected += verilator
selected += iverilog

# Pin GHDL version (typically to the latest one in which our designs work and
# where we have no troubles generating code coverage)
GHDL_VERSION = master

# Select ghdl-yosys-plugin version. This version cannot be much more advanced
# in time than the ghdl version, since it uses symbols defined in ghdl
GHDLSYNTH_VERSION = master

# Pin nextpnr version. As of end of 2024 / beginning of 2025, latest versions
# require a version of cmake (3.25) that is not available in older distros
# (debian 11, ubuntu 18 and ubuntu 22)
NEXTPNR_VERSION =

# Pin versions of solvers used by SymbiYosys
#
# Latest z3 versions require format.h, which comes which gcc-13, which is not
# avaiable in debian:12 and ubuntu:22.04
Z3_VERSION = z3-4.15.4
