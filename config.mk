# Where to install
PREFIX = /opt/fosshdl

# If your user has write permissions in the install location (such as when
# installing in your $(HOME), you can comment the SUDO definition line below
# and binaries won't be installed by root
SUDO = sudo

# Use a GCC version supported by GHDL (supported versions are listed on
# https://ghdl.readthedocs.io/en/latest/building/gcc/index.html)
# Keep in mind that not all gcc versions can generate code coverage with GHDL
GCC_VERSION = 7.5.0

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

# Latest GHDL version that generates code coverage with the GCC BACKEND (that I
# have tested)
GHDL_VERSION = v1.0.0-r144-g68a7f85c

# Select ghdl-yosys-plugin version
GHDLSYNTH_VERSION = 9e11f71e1d06f4cfac0b62d5dbe324fbcae6c44e

# Latest UVVM version that compiles with GHDL
UVVM_VERSION = v2019.09.02

# Cocotb, vunit and amaranth-hdl must be installed using pip, so they will be
# installed in the Dockerfile instead of compiled
#selected += cocotb
#selected += vunit
#selected += amaranth-hdl
