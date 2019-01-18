# Makefile to make a binary distribution of the FOSS HDL/FPGA tools for teaching

#include config.mk

# Set to "yes" if using the full yosys version with the Verific VHDL frontend,
# set to any other value if using the fully open source yoys version (Verilog
# only).
USE_SYMBIOTIC = no

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
	dists += yosys/yosys
endif

targets += ghdl
targets += UVVM
targets += arachne-pnr
targets += nextpnr
targets += icestorm
#targets += icestudio
#targets += fpga-knife

dists += ghdl/build/gcc-objs/gcc/ghdl
#dists += UVVM
dists += arachne-pnr/arachne-pnrdist
dists += nextpnr/nextpnrdist
dists += icestorm/icepack
#dists += icestudio \
#dists += fpga-knife

installed += $(PREFIX)/bin/yosys
installed += $(PREFIX)/bin/ghdl
installed += $(PREFIX)/bin/arachne-pnr


.PHONY: all
all: $(dists)

.PHONY: all
install: $(installed)

echo-targets:
	@echo targets: $(targets)
	@echo dists: $(dists)
	@echo installed: $(installed)

#Get code from repositories

ghdl:
	git clone https://github.com/ghdl/ghdl

UVVM:
	git clone https://github.com/UVVM/UVVM

yosys:
	git clone https://github.com/YosysHQ/yosys

arachne-pnr:
	git clone https://github.com/YosysHQ/arachne-pnr

nextpnr:
	git clone https://github.com/YosysHQ/nextpnr

icestorm:
	git clone https://github.com/cliffordwolf/icestorm

icestudio:
	git clone https://github.com/FPGAwars/icestudio

fpga-knife:
	git clone https://github.com/qarlosalberto/fpga-knife

# Build GHDL with the gcc frontend so code coverage is available (requires
# GNAT) https://ghdl.readthedocs.io/en/latest/building/gcc/GNULinux-GNAT.html
ghdl/build/gcc-objs/gcc/ghdl: | ghdl gcc-$(GCC_VERSION)
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
	cd ../ && \
	make ghdllib

$(PREFIX)/bin/ghdl: ghdl/build/gcc-objs/gcc/ghdl
	cd ghdl/build && \
	make install

gcc-$(GCC_VERSION): gcc-$(GCC_VERSION).tar.gz
	tar xzf $<
	cd $@ && ./contrib/download_prerequisites

gcc-$(GCC_VERSION).tar.gz:
	wget https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz

symbiotic-$(SYMBIOTIC_VERSION): symbiotic-$(SYMBIOTIC_VERSION).tar.gz
	tar xzf $<

# nextpnr and arachne-pnr require icestorm installed
nextpnr/nextpnrdist: | nextpnr $(PREFIX)/bin/icepack
	cd nextpnr && \
	cmake -DARCH=ice40 -DICEBOX_ROOT="$(PREFIX)/share/icebox" -DCMAKE_INSTALL_PREFIX=$(PREFIX) && \
	make && \
	make install

arachne-pnr/arachne-pnr/bin/arachne-pnr: | arachne-pnr $(PREFIX)/bin/icepack
	make -C arachne-pnr PREFIX=$(PREFIX)

$(PREFIX)/bin/arachne-pnr: arachne-pnr/arachne-pnr/bin/arachne-pnr
	make -C arachne-pnr install PREFIX=$(PREFIX)

icestorm/icepack/icepack: | icestorm
	make -C icestorm

$(PREFIX)/bin/icepack: icestorm/icepack/icepack
	make -C icestorm install PREFIX=$(PREFIX)

yosys/yosys: | yosys
	make -C yosys config-gcc
	make -C yosys PREFIX=$(PREFIX)

$(PREFIX)/bin/yosys: yosys/yosys
	make -C yosys install PREFIX=$(PREFIX)

clean:
	rm -rf $(targets)
	rm -rf gcc-$(GCC_VERSION) gcc-$(GCC_VERSION).tar.gz
	rm -rf symbiotic-$(SYMBIOTIC_VERSION)

