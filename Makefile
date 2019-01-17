# Makefile to make a binary distribution of the FOSS HDL/FPGA tools for teaching

#include config.mk

# Set to "yes" if using the full yosys version with the Verific VHDL frontend,
# set to any other value if using the fully open source yoys version (Verilog
# only).
USE_SYMBIOTIC = yes

# Install prefix (default: user home at ETSI's CdC computers)
# If installing to system directories, change all "make install *" for "sudo
# make install *"
PREFIX = $(HOME)/opt

# If using full yosys, put the provided tar.gz in this directory and put here
# the version number provided by SymbioticEDA
SYMBIOTIC_VERSION = 20190105A

# Use a GCC version supported by GHDL (supported versions are listed on
# https://ghdl.readthedocs.io/en/latest/building/gcc/index.html)
GCC_VERSION = 7.3.0

# Put each build log in its own file. Comment to see all logs on the command
# line
# (Commented out because it does not work yet)
#DUMP_LOG = &> $@.log

ifeq ($(USE_SYMBIOTIC),yes)
	targets += symbiotic-$(SYMBIOTIC_VERSION)
else
	targets += yosys
endif

targets += ghdl \
	   UVVM \
	   arachne-pnr \
	   nextpnr \
	   icestorm \
	   icestudio \
	   fpga-knife


all: $(targets)

echo-targets:
	echo targets: $(targets)

ghdl:
	git clone https://github.com/ghdl/ghdl $(DUMP_LOG)

UVVM:
	git clone https://github.com/UVVM/UVVM $(DUMP_LOG)

yosys:
	git clone https://github.com/YosysHQ/yosys $(DUMP_LOG)

arachne-pnr:
	git clone https://github.com/YosysHQ/arachne-pnr $(DUMP_LOG)

nextpnr:
	git clone https://github.com/YosysHQ/nextpnr $(DUMP_LOG)

icestorm:
	git clone https://github.com/cliffordwolf/icestorm $(DUMP_LOG)

icestudio:
	git clone https://github.com/FPGAwars/icestudio $(DUMP_LOG)

fpga-knife:
	git clone https://github.com/qarlosalberto/fpga-knife $(DUMP_LOG)

# Build GHDL with the gcc frontend so code coverage is available (requires
# GNAT) https://ghdl.readthedocs.io/en/latest/building/gcc/GNULinux-GNAT.html
ghdl/ghdllib: ghdl gcc-$(VERSION)
	cd ghdl && \
	mkdir -p build && \
	cd build && \
	../configure --with-gcc=../../gcc-7.3.0 --prefix=$(PREFIX) && \
	make copy-sources && \
	mkdir -p gcc-objs; cd gcc-objs && \
	../../../gcc-7.3.0/configure --prefix=$(PREFIX) --enable-languages=c,vhdl \
		-disable-bootstrap --disable-lto --disable-multilib --disable-libssp \
		-disable-libgomp --disable-libquadmath && \
	make && \
	make install && \
	cd ../../ && \
	make ghdllib && \
	make install $(DUMP_LOG)

gcc-$(GCC_VERSION): gcc-$(GCC_VERSION).tar.gz
	tar xzf $<
	cd $@ && ./contrib/download_prerequisites

gcc-$(GCC_VERSION).tar.gz:
	wget https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz

symbiotic-$(SYMBIOTIC_VERSION): symbiotic-$(SYMBIOTIC_VERSION).tar.gz
	tar xzf $<

# nextpnr and arachne-pnr require icestorm installed
nextpnr/nextpnrdist: nextpnr icestorm/icestormdist
	cd nextpnr && \
	cmake -DARCH=ice40 -DICEBOX_ROOT="$(PREFIX)/share/icebox" -DCMAKE_INSTALL_PREFIX=$(PREFIX) && \
	make && \
	make install

arachne-pnr/arachne-pnrdist: arachne-pnr icestorm/icestormdist
	make -C arachne-pnr PREFIX=$(PREFIX)
	make -C arachne-pnr install PREFIX=$(PREFIX)

icestorm/icestormdist: icestorm
	make -C icestorm
	make -C icestorm install PREFIX=$(PREFIX)

clean:
	rm -rf $(targets)
	rm -rf gcc-$(GCC_VERSION) gcc-$(GCC_VERSION).tar.gz
	rm -rf symbiotic-$(SYMBIOTIC_VERSION)

