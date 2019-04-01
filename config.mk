# Where to install 
# If installing to system directories, change all "make install *" for "sudo
# make install *"
PREFIX = /opt/fosshdl-symbiotic

# Set to "yes" if using the full yosys version with the Verific VHDL frontend,
# set to any other value if using the open source yoys version (Verilog only).
USE_SYMBIOTIC = yes

# If using full yosys, put the provided tar.gz in this directory and put here
# the version number provided by SymbioticEDA
SYMBIOTIC_VERSION = 20190312A

# Use a GCC version supported by GHDL (supported versions are listed on
# https://ghdl.readthedocs.io/en/latest/building/gcc/index.html)
GCC_VERSION = 7.3.0

# List of software to compile and install. Comment any one you don't want.
selected += yosys
selected += ghdl
selected += uvvm 
selected += arachne-pnr
selected += nextpnr
selected += icestorm

# Unsupported, but planned:
#selected += migen
#selected += iverilog
#selected += verilator
#selected += icestudio
#selected += fusesoc
#selected += fpga-knife
