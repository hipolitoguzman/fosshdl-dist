# Where to install
# Make sure you have write permissions in the install location
# If installing to system directories, change all "make install *" for "sudo
# make install *"
PREFIX = $(HOME)/opt/fosshdl

# Set to "yes" if using the full yosys version with the Verific VHDL frontend,
# set to any other value if using the open source yosys version (Verilog only).
USE_SYMBIOTIC = yes

# If using full yosys, put the provided tar.gz in this directory and put here
# the version number provided by SymbioticEDA
SYMBIOTIC_VERSION = 20200402A-sevilla-university

# Use a GCC version supported by GHDL (supported versions are listed on
# https://ghdl.readthedocs.io/en/latest/building/gcc/index.html)
GCC_VERSION = 9.3.0

# List of software to compile and install. Comment any one you don't want.
#selected += yosys
selected += ghdl
#selected += uvvm
#selected += osvvm
#selected += arachne-pnr
selected += nextpnr
#selected += icestorm
#selected += icestudio
selected += cocotb
selected += verilator
selected += iverilog

# Latest UVVM version that compiles with GHDL
UVVM_VERSION = v2019.09.02

# Unsupported, but planned:
#selected += migen
#selected += fusesoc
#selected += theroshdl 
