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
selected += ghdl
selected += ghdl-yosys-plugin
#selected += uvvm
#selected += osvvm
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

# Latest UVVM version that compiles with GHDL
#UVVM_VERSION = v2019.09.02

# Cocotb, vunit and amaranth-hdl must be installed using pip, so they will be
# installed in the Dockerfile instead of compiled
#selected += cocotb
#selected += vunit
#selected += amaranth-hdl
