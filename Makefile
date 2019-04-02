# Makefile to make a binary distribution of the FOSS HDL/FPGA tools for teaching

include config.mk

# Put each build log in its own file. Comment to see all logs on the command
# line
# (Commented out because it does not work yet)
#DUMP_LOG = &> $@.log

# Select what to install depending on what was selected in config.mk

ifneq (,$(findstring yosys, $(selected)))
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
endif

ifneq (,$(findstring ghdl, $(selected)))
	repos += ghdl
	binaries += ghdl/build/gcc-objs/gcc/ghdl
	install-targets += $(PREFIX)/bin/ghdl
endif

ifneq (,$(findstring uvvm, $(selected)))
	repos += uvvm
	binaries += uvvm_bin
	install-targets += $(PREFIX)/uvvm_bin
endif

#ifneq (,$(findstring cocotb, $(selected)))
#	repos += cocotb
#	binaries += cocotb_bin
#	install-targets += $(PREFIX)/cocotb_bin
#endif

ifneq (,$(findstring arachne-pnr, $(selected)))
	repos += arachne-pnr
	binaries += arachne-pnr/bin/arachne-pnr
	install-targets += $(PREFIX)/bin/arachne-pnr
endif

ifneq (,$(findstring nextpnr, $(selected)))
	repos += nextpnr
	binaries += nextpnr/nextpnr-ice40
	install-targets += $(PREFIX)/bin/nextpnr-ice40
endif

ifneq (,$(findstring icestorm, $(selected)))
	repos += icestorm
	binaries += icestorm/icepack/icepack
	install-targets += $(PREFIX)/bin/icepack
endif

#repos += migen
#repos += iverilog
#repos += verilator
#repos += icestudio
#repos += fusesoc
#repos += fpga-knife
#binaries += migen/whatever
#binaries += iverilog/whatever
#binaries += verilator/whatever
#binaries += icestudio
#binaries += fusesoc
#binaries += fpga-knife

#install-targets += $(PREFIX)/bin/migenwhatever
#install-targets += $(PREFIX)/bin/iverilogwhatever
# Verilator compile instructions: https://www.veripool.org/projects/verilator/wiki/Installing
#install-targets += $(PREFIX)/bin/verilatorwhatever
#install-targets += $(PREFIX)/bin/fusesocwhatever
#install-targets += $(PREFIX)/bin/fpga-knifewhatever

.PHONY: all
all: $(binaries)

.PHONY: install
install: $(install-targets)

# Check selected tools
echo-targets:
	@echo selected: $(selected)
	@echo repos: $(repos)
	@echo binaries: $(binaries)
	@echo install-targets: $(install-targets)

#Get code from repositories

ghdl:
	git clone https://github.com/ghdl/ghdl

uvvm:
	git clone https://github.com/UVVM/UVVM uvvm

cocotb:
	git clone https://github.com/potentialventures/cocotb

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


# Compile GHDL
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
	make
       
# GHDL must be installed to compile ghdllib
ghdl/build/grt/libgrt.a: $(PREFIX)/bin/ghdl
	cd ghdl/build && \
	make ghdllib

# Install GHDL
# Use this target to explicitly install ghdl before compiling ghdllib
.PHONY: install-ghdl
install-ghdl: $(PREFIX)/bin/ghdl

$(PREFIX)/bin/ghdl: ghdl/build/gcc-objs/gcc/ghdl
	cd ghdl/build/gcc-objs && \
	make install

# Install ghdllib
$(PREFIX)/lib/ghdl/libgrt.a: ghdl/build/grt/libgrt.a
	cd ghdl/build && \
	make install

# Download and untar GCC (needed for GHDL)
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
# to make a floor() operation on the 'modified' date of the installed
# executable, causing the target to be be always outdated 
$(PREFIX)/bin/nextpnr-ice40: | nextpnr/nextpnr-ice40
	cd nextpnr && \
	make install


# Compile and install arachne-pnr. Deprecated by nextpnr, so typically not used.

arachne-pnr/bin/arachne-pnr: | arachne-pnr $(PREFIX)/bin/icepack
	make -C arachne-pnr PREFIX=$(PREFIX)

$(PREFIX)/bin/arachne-pnr: arachne-pnr/bin/arachne-pnr
	make -C arachne-pnr install PREFIX=$(PREFIX)


# Compile and install icestorm

icestorm/icepack/icepack: | icestorm
	make -C icestorm

$(PREFIX)/bin/icepack: icestorm/icepack/icepack
	make -C icestorm install PREFIX=$(PREFIX)


# Compile and install yosys, if using the open source version

yosys/yosys: | yosys
	make -C yosys config-clang
	make -C yosys PREFIX=$(PREFIX)

ifneq ($(USE_SYMBIOTIC),yes)
$(PREFIX)/bin/yosys: yosys/yosys
	make -C yosys install PREFIX=$(PREFIX)
endif


# Untar and install symbiotic suite, if using the paid yosys version

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


# Compile and install uvvm
# This has to be done using GHDL so $(PREFIX)/bin should be in the user's $(PATH)
uvvm_bin: | uvvm $(PREFIX)/bin/ghdl $(PREFIX)/lib/ghdl/libgrt.a
	export PATH=$(PREFIX)/bin:$(PATH) && $(PREFIX)/lib/ghdl/vendors/compile-uvvm.sh --all --src uvvm --out uvvm_bin

$(PREFIX)/uvvm_bin: uvvm_bin
	cp -R $< $@
	cp -R uvvm $(PREFIX)/uvvm_src  # Also copy sources just in case?


# Clean

clean:
	rm -rf $(repos)
	rm -rf gcc-$(GCC_VERSION) gcc-$(GCC_VERSION).tar.gz
	rm -rf symbiotic-$(SYMBIOTIC_VERSION)
	rm -rf yosys

