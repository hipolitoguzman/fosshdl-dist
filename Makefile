# Makefile to make a binary distribution of the FOSS HDL/FPGA tools for teaching

#include config.mk

# Set to "yes" if using the full yosys version with the Verific VHDL frontend,
# set to any other value if using the fully open source yoys version (Verilog
# only).
USE_SYMBIOTIC = yes

# Install prefix (default: user home at ETSI's CdC computers)
# If installing to system directories, change all "make install *" for "sudo
# make install *"
PREFIX = $(HOME)/opt/fosshdl-symbiotic

# If using full yosys, put the provided tar.gz in this directory and put here
# the version number provided by SymbioticEDA
SYMBIOTIC_VERSION = 20190204A

# Use a GCC version supported by GHDL (supported versions are listed on
# https://ghdl.readthedocs.io/en/latest/building/gcc/index.html)
GCC_VERSION = 7.3.0

# Put each build log in its own file. Comment to see all logs on the command
# line
# (Commented out because it does not work yet)
#DUMP_LOG = &> $@.log

ifeq ($(USE_SYMBIOTIC),yes)
	repos += symbiotic-$(SYMBIOTIC_VERSION)
	binaries += symbiotic-$(SYMBIOTIC_VERSION)/bin/yosys
	install-targets += $(PREFIX)/bin/yosys
	install-targets += $(PREFIX)/symbiotic.lic
else
	repos += yosys
	binaries += yosys/yosys
	install-targets += $(PREFIX)/bin/yosys
endif

repos += ghdl
repos += uvvm
repos += arachne-pnr
repos += nextpnr
repos += icestorm
repos += migen
repos += iverilog
#repos += icestudio
#repos += fpga-knife


binaries += ghdl/build/gcc-objs/gcc/ghdl
binaries += uvvm_bin
binaries += arachne-pnr/bin/arachne-pnr
binaries += nextpnr/nextpnr-ice40
binaries += icestorm/icepack/icepack
#binaries += migen/whatever
#binaries += iverilog/whatever
#binaries += icestudio
#binaries += fpga-knife

install-targets += $(PREFIX)/bin/ghdl
install-targets += $(PREFIX)/uvvm_bin
install-targets += $(PREFIX)/bin/arachne-pnr
install-targets += $(PREFIX)/bin/nextpnr-ice40
install-targets += $(PREFIX)/bin/icepack
#install-targets += $(PREFIX)/bin/migenwhatever
#install-targets += $(PREFIX)/bin/iverilogwhatever

.PHONY: all
all: $(binaries)

.PHONY: all
install: $(install-targets)

echo-targets:
	@echo repos: $(repos)
	@echo binaries: $(binaries)
	@echo install-targets: $(install-targets)

#Get code from repositories

ghdl:
	git clone https://github.com/ghdl/ghdl

uvvm:
	git clone https://github.com/UVVM/UVVM uvvm

yosys:
	git clone https://github.com/YosysHQ/yosys

arachne-pnr:
	git clone https://github.com/YosysHQ/arachne-pnr

nextpnr:
	git clone https://github.com/YosysHQ/nextpnr

icestorm:
	git clone https://github.com/cliffordwolf/icestorm

migen:
	git clone https://github.com/m-labs/migen

iverilog:
	git clone https://github.com/steveicarus/iverilog

icestudio:
	git clone https://github.com/FPGAwars/icestudio

fpga-knife:
	git clone https://github.com/qarlosalberto/fpga-knife


# Compile and install GHDL
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


# Compile and install nextpnr

nextpnr/nextpnr-ice40: | nextpnr $(PREFIX)/bin/icepack
	cd nextpnr && \
	cmake -DARCH=ice40 -DICEBOX_ROOT="$(PREFIX)/share/icebox" -DCMAKE_INSTALL_PREFIX=$(PREFIX) && \
	make

# I had to make a quick hack here and add the | because the installation seems
# to floor() the 'modified' date of the installed executable, causing the
# target to be be always outdated 
$(PREFIX)/bin/nextpnr-ice40: | nextpnr/nextpnr-ice40
	cd nextpnr && \
	make install


# Compile and install arachne-pnr

arachne-pnr/bin/arachne-pnr: | arachne-pnr $(PREFIX)/bin/icepack
	make -C arachne-pnr PREFIX=$(PREFIX)

$(PREFIX)/bin/arachne-pnr: arachne-pnr/bin/arachne-pnr
	make -C arachne-pnr install PREFIX=$(PREFIX)


# Compile and install icestorm

icestorm/icepack/icepack: | icestorm
	make -C icestorm

$(PREFIX)/bin/icepack: icestorm/icepack/icepack
	make -C icestorm install PREFIX=$(PREFIX)


# Compile and install yosys

yosys/yosys: | yosys
	make -C yosys config-clang
	make -C yosys PREFIX=$(PREFIX)

ifneq ($(USE_SYMBIOTIC),yes)
$(PREFIX)/bin/yosys: yosys/yosys
	make -C yosys install PREFIX=$(PREFIX)
endif

# Compile and install uvvm
# This has to be done using GHDL so $(PREFIX)/bin should be exported
uvvm_bin: uvvm $(PREFIX)/bin/ghdl
	export PATH=$(PREFIX)/bin:$(PATH) && $(PREFIX)/lib/ghdl/vendors/compile-uvvm.sh --all --src uvvm --out uvvm_bin

$(PREFIX)/uvvm_bin: uvvm_bin
	cp -R $< $@
	cp -R uvvm $(PREFIX)/uvvm_src  # Also copy sources just in case?

# Untar and install symbiotic

symbiotic-$(SYMBIOTIC_VERSION)/bin/yosys: | symbiotic-$(SYMBIOTIC_VERSION).tar.gz
	tar xzf symbiotic-$(SYMBIOTIC_VERSION).tar.gz

ifeq ($(USE_SYMBIOTIC),yes)
$(PREFIX)/bin/yosys: | symbiotic-$(SYMBIOTIC_VERSION)/bin/yosys
	mkdir -p $(PREFIX)
	cp -Rv symbiotic-$(SYMBIOTIC_VERSION)/* $(PREFIX)
endif

$(PREFIX)/symbiotic.lic: symbiotic.lic
	mkdir -p $(PREFIX)
	cp symbiotic.lic $(PREFIX)/symbiotic.lic


# Clean

clean:
	rm -rf $(repos)
	rm -rf gcc-$(GCC_VERSION) gcc-$(GCC_VERSION).tar.gz
	rm -rf symbiotic-$(SYMBIOTIC_VERSION)
	rm -rf yosys

