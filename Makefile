# Makefile to make a binary distribution of the FOSS HDL/FPGA tools for teaching

include config.mk

# Put each build log in its own file. Comment to see all logs on the command
# line
# (Commented out because it does not work yet)
#DUMP_LOG = &> $@.log

# Select what to install depending on what was selected in config.mk

install-targets += $(PREFIX)/env.rc

ifneq (,$(findstring yosys, $(selected)))
	repos += yosys
	binaries += yosys/yosys
	install-targets += $(PREFIX)/bin/yosys
endif

ifneq (,$(findstring SymbiYosys, $(selected)))
	repos += symbiyosys
	repos += yices2
	repos += z3
	repos += super-prove-build
	repos += extavy
	repos += boolector
	install-targets += $(PREFIX)/bin/sby
	install-targets += $(PREFIX)/bin/yices
	install-targets += $(PREFIX)/bin/z3
	install-targets += $(PREFIX)/bin/suprove
	install-targets += $(PREFIX)/bin/avy
	install-targets += $(PREFIX)/bin/boolector
endif

ifneq (,$(findstring ghdl, $(selected)))
	repos += ghdl
	binaries += ghdl/build/gcc-objs/gcc/ghdl
	install-targets += $(PREFIX)/bin/ghdl
	install-targets += $(PREFIX)/lib/ghdl/libgrt.a
endif

ifneq (,$(findstring ghdl-yosys-plugin, $(selected)))
	repos += ghdl-yosys-plugin
	binaries += ghdl-yosys-plugin/ghdl.so
	install-targets += $(PREFIX)/share/yosys/plugins/ghdl.so
endif

ifneq (,$(findstring uvvm, $(selected)))
	repos += uvvm
	binaries += uvvm_bin
	install-targets += $(PREFIX)/uvvm_bin
endif

ifneq (,$(findstring osvvm, $(selected)))
	repos += osvvm
	binaries += osvvm_bin
	install-targets += $(PREFIX)/osvvm_bin
endif

ifneq (,$(findstring verilator, $(selected)))
	repos += verilator
	binaries += verilator/verilator
	install-targets += $(PREFIX)/bin/verilator
endif

ifneq (,$(findstring iverilog, $(selected)))
	repos += iverilog
	binaries += iverilog/iverilog
	install-targets += $(PREFIX)/bin/iverilog
endif

#ifneq (,$(findstring cocotb, $(selected)))
#	repos += cocotb
#	install-targets += $(PREFIX)/bin/cocotb-config
#endif

#ifneq (,$(findstring vunit, $(selected)))
#	repos += vunit
#	install-targets += $(PREFIX)/lib/python3.6/site-packages/vunit/vunit_cli.py
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

ifneq (,$(findstring icestudio, $(selected)))
	repos += icestudio
	install-targets += $(PREFIX)/bin/icestudio
endif




#repos += migen
#repos += fusesoc
#repos += theroshdl
#binaries += migen/whatever
#binaries += fusesoc
#binaries += theroshdl 

#install-targets += $(PREFIX)/bin/migenwhatever
#install-targets += $(PREFIX)/bin/fusesocwhatever
#install-targets += $(PREFIX)/bin/theroshdlwhatever

.PHONY: all
all: $(binaries)

.PHONY: install
install: $(install-targets)

$(PREFIX)/env.rc: env.rc
	$(SUDO) mkdir -p $(PREFIX)
	$(SUDO) cp env.rc $(PREFIX)/env.rc

# It seems that for env.rc we have to put ghdl's gcc before system gcc in order
# for code coverage to work correcly, unless we use the exact system version.
# But typically we have to use a different one because gcc 9 seems to break
# ghdl's code coverage
env.rc:
	echo 'export PATH=$(PREFIX)/bin:$$PATH' >> $@
	echo 'export VUNIT_SIMULATOR=ghdl' >> $@
	echo 'export GHDL_PLUGIN_MODULE=ghdl' >> $@

# Check selected tools
echo-targets:
	@echo selected: $(selected)
	@echo repos: $(repos)
	@echo binaries: $(binaries)
	@echo install-targets: $(install-targets)

#Get code from repositories

yosys:
	git clone https://github.com/YosysHQ/yosys

symbiyosys:
	git clone https://github.com/YosysHQ/SymbiYosys symbiyosys

yices2:
	git clone https://github.com/SRI-CSL/yices2.git

z3:
	git clone https://github.com/Z3Prover/z3.git

super-prove-build:
	git clone --recursive https://github.com/sterin/super-prove-build

# For avy to compile with gcc 9.3.0 (the one in ubuntu 20.04 we need to apply
# this patch from Michael Jorgensen:
# https://github.com/MJoergen/formal/blob/main/INSTALL.md
# And this third change:
# https://github.com/YosysHQ/fpga-toolchain/issues/57
# We will just perform a substitution in the affected files
extavy:
	git clone https://bitbucket.org/arieg/extavy.git
	cd extavy && git submodule update --init
	sed -i 's/bool isSolved () { return m_Trivial || m_State || !m_State; }/bool isSolved () { return bool{m_Trivial || m_State || !m_State}; }/' extavy/avy/src/ItpGlucose.h
	sed -i 's/return tobool (m_pSat->modelValue(x));/boost::logic::tribool y = tobool (m_pSat->modelValue(x));\nreturn bool{y};/' extavy/avy/src/ItpGlucose.h
	sed -i 's/bool isSolved () { return m_Trivial || m_State || !m_State; }/bool isSolved () { return bool{m_Trivial || m_State || !m_State}; }/' extavy/avy/src/ItpMinisat.h

boolector:
	git clone https://github.com/boolector/boolector

ghdl:
	git clone https://github.com/ghdl/ghdl
	cd ghdl && git checkout $(GHDL_VERSION)

ghdl-yosys-plugin:
	git clone https://github.com/ghdl/ghdl-yosys-plugin
	cd ghdl-yosys-plugin && git checkout $(GHDLSYNTH_VERSION)

uvvm:
	git clone https://github.com/UVVM/UVVM uvvm --branch $(UVVM_VERSION)

osvvm:
	git clone https://github.com/OSVVM/OSVVM osvvm

cocotb:
	git clone https://github.com/cocotb/cocotb

vunit:
	git clone --recurse-submodules https://github.com/vunit/vunit

arachne-pnr:
	git clone https://github.com/YosysHQ/arachne-pnr

nextpnr:
	git clone --recursive https://github.com/YosysHQ/nextpnr

icestorm:
	git clone https://github.com/cliffordwolf/icestorm

migen:
	git clone https://github.com/m-labs/migen

iverilog:
	git clone https://github.com/steveicarus/iverilog

verilator:
	git clone https://github.com/verilator/verilator

icestudio: $(PREFIX)/icestudio

$(PREFIX)/icestudio:
	git clone https://github.com/FPGAwars/icestudio $(PREFIX)/icestudio


# Compile GHDL
# Build GHDL with the gcc frontend so code coverage is available (requires
# GNAT) https://ghdl.readthedocs.io/en/latest/building/gcc/GNULinux-GNAT.html
# ./configure option --enable-synth enables VHDL synthesis (currently beta)
# If system gcc was compiled with the --enable-default-pie option, pass that
# option to ghdl's gcc's configure
ENABLE_DEFAULT_PIE = $(shell gcc -v 2>&1 | grep -o "\-\-enable-default-pie")
ghdl/build/gcc-objs/gcc/ghdl: | ghdl gcc-$(GCC_VERSION)
	cd ghdl && \
	mkdir -p build && \
	cd build && \
	../configure --with-gcc=../../gcc-$(GCC_VERSION) --prefix=$(PREFIX) && \
	make copy-sources && \
	mkdir -p gcc-objs; cd gcc-objs && \
	../../../gcc-$(GCC_VERSION)/configure --prefix=$(PREFIX) --enable-languages=c,vhdl \
		--disable-bootstrap --disable-lto --disable-multilib --disable-libssp \
		--disable-libgomp --disable-libquadmath $(ENABLE_DEFAULT_PIE) \
	        --enable-synth && \
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
	$(SUDO) make install MAKEINFO=true

# Install ghdllib
$(PREFIX)/lib/ghdl/libgrt.a: ghdl/build/grt/libgrt.a
	cd ghdl/build && \
	$(SUDO) make install

# Download and untar GCC (needed for GHDL)
gcc-$(GCC_VERSION): gcc-$(GCC_VERSION).tar.gz
	tar xzf $<
	cd $@ && sed -i 's/ftp/http/' contrib/download_prerequisites && ./contrib/download_prerequisites

gcc-$(GCC_VERSION).tar.gz:
	wget https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz


# Compile and install ghdl-yosys-plugin
ghdl-yosys-plugin/ghdl.so: ghdl-yosys-plugin $(PREFIX)/bin/ghdl $(PREFIX)/bin/yosys $(PREFIX)/lib/ghdl/libgrt.a $(PREFIX)/env.rc
	cd ghdl-yosys-plugin && \
	. $(PREFIX)/env.rc && \
	make

$(PREFIX)/share/yosys/plugins/ghdl.so: ghdl-yosys-plugin/ghdl.so
	cd ghdl-yosys-plugin && \
	. $(PREFIX)/env.rc && \
	make install

# Compile and install nextpnr

nextpnr/nextpnr-ice40: $(PREFIX)/bin/icepack | nextpnr $(PREFIX)/bin/icepack
	cd nextpnr && \
	cmake -DARCH=ice40 -DBUILD_GUI=ON -DICESTORM_INSTALL_PREFIX=$(PREFIX) -DCMAKE_INSTALL_PREFIX=$(PREFIX) && \
	make

# I had to make a quick hack here and add the | because the installation seems
# to make a floor() operation on the 'modified' date of the installed
# executable, causing the target to be be always outdated 
$(PREFIX)/bin/nextpnr-ice40: | nextpnr/nextpnr-ice40
	cd nextpnr && \
	$(SUDO) make install


# Compile and install arachne-pnr. Deprecated by nextpnr, so typically not used.

arachne-pnr/bin/arachne-pnr: | arachne-pnr $(PREFIX)/bin/icepack
	make -C arachne-pnr PREFIX=$(PREFIX)

$(PREFIX)/bin/arachne-pnr: arachne-pnr/bin/arachne-pnr
	make -C arachne-pnr install PREFIX=$(PREFIX)


# Compile and install icestorm

icestorm/icepack/icepack: | icestorm
	make -C icestorm

$(PREFIX)/bin/icepack: icestorm/icepack/icepack
	$(SUDO) make -C icestorm install PREFIX=$(PREFIX)


# Install icestudio and create a script to launch it

$(PREFIX)/bin/icestudio: $(PREFIX)/icestudio
	cd $(PREFIX)/icestudio && npm install
	echo "cd $(PREFIX)/bin/icestudio && npm start" >> $(PREFIX)/bin/icestudio
	chmod +x $(PREFIX)/bin/icestudio

# Compile and install yosys, if using the open source version

yosys/yosys: | yosys
	make -C yosys config-clang
	make -C yosys PREFIX=$(PREFIX)

ifneq ($(USE_SYMBIOTIC),yes)
$(PREFIX)/bin/yosys: yosys/yosys
	make -C yosys install PREFIX=$(PREFIX)
endif

# Compile and install symbiyosys. This is all done in one step since it is all
# grouped into a single step in symbiosys' Makefile
$(PREFIX)/bin/sby: symbiyosys
	$(SUDO) make -C symbiyosys PREFIX=$(PREFIX) install

# Compile and install the solvers that SymbiYosys can use
# Instructions came from here:
# https://yosyshq.readthedocs.io/projects/sby/en/latest/install.html#prerequisites
# TODO: check for correctness, add to binaries list
$(PREFIX)/bin/yices: yices2
	cd yices2 && \
	autoconf && \
	./configure --prefix=$(PREFIX) && \
	make && \
	$(SUDO) make install

$(PREFIX)/bin/z3: z3
	cd z3 && \
	python scripts/mk_make.py --prefix=$(PREFIX) && \
	cd build && \
	make && \
	$(SUDO) make install

$(PREFIX)/super_prove/bin/super_prove.sh: | super-prove-build
	cd super-prove-build && mkdir -p build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX) -G Ninja .. && \
	ninja && \
	ninja package && \
	cp super_prove-*-Release.tar.gz super_prove.tar.gz && \
	$(SUDO) tar -C $(PREFIX) -x --file super_prove.tar.gz

$(PREFIX)/bin/suprove: $(PREFIX)/super_prove/bin/super_prove.sh
	echo '#!/bin/bash' > $@
	echo 'tool=super_prove; if [ "$$1" != "$${1#+}" ]; then tool="$${1#+}"; shift; fi' >> $@
	echo 'exec $(PREFIX)/super_prove/bin/$${tool}.sh "$$@"' >> $@
	$(SUDO) chmod +x $@

$(PREFIX)/bin/avy: extavy
	cd extavy && mkdir -p build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX) .. && \
	make && \
	pwd && \
	$(SUDO) cp avy/src/avy $(PREFIX)/bin && \
	$(SUDO) cp avy/src/avybmc $(PREFIX)/bin

$(PREFIX)/bin/boolector: boolector
	cd boolector && \
	./contrib/setup-btor2tools.sh && \
	./contrib/setup-lingeling.sh && \
	./configure.sh --prefix $(PREFIX) && \
	make -C build && \
	$(SUDO) cp build/bin/boolector $(PREFIX)/bin/ && \
	$(SUDO) cp build/bin/btor* $(PREFIX)/bin/ && \
	$(SUDO) cp deps/btor2tools/bin/btorsim $(PREFIX)/bin/

# Compile and install uvvm
# This has to be done using GHDL so $(PREFIX)/bin should be in the user's $(PATH)
uvvm_bin: | uvvm $(PREFIX)/bin/ghdl $(PREFIX)/lib/ghdl/libgrt.a
	export PATH=$(PREFIX)/bin:$(PATH) && $(PREFIX)/lib/ghdl/vendors/compile-uvvm.sh --all --src uvvm --out uvvm_bin

$(PREFIX)/uvvm_bin: uvvm_bin
	cp -R $< $@
	cp -R uvvm $(PREFIX)/uvvm_src  # Also copy sources just in case?


# Compile and install osvvm
# This has to be done using GHDL so $(PREFIX)/bin should be in the user's $(PATH)
osvvm_bin: | osvvm $(PREFIX)/bin/ghdl $(PREFIX)/lib/ghdl/libgrt.a
	export PATH=$(PREFIX)/bin:$(PATH) && $(PREFIX)/lib/ghdl/vendors/compile-osvvm.sh --all --src osvvm --out osvvm_bin

$(PREFIX)/osvvm_bin: osvvm_bin
	cp -R $< $@
	cp -R osvvm $(PREFIX)/osvvm_src  # Also copy sources just in case?


# Install cocotb
#$(PREFIX)/bin/cocotb-config: cocotb
#	$(SUDO) pip3 install --prefix $(PREFIX) ./cocotb

# Install vunit
#$(PREFIX)/lib/python3.6/site-packages/vunit/vunit_cli.py: vunit
#	$(SUDO) pip3 install --prefix $(PREFIX) ./vunit

# Compile and install verilator
verilator/verilator: verilator
	cd verilator && autoconf
	cd verilator && ./configure --prefix=$(PREFIX)
	cd verilator && make

$(PREFIX)/bin/verilator: verilator/verilator
	cd verilator && $(SUDO) make install

# Compile and install icarus verilog 
iverilog/iverilog: iverilog
	cd iverilog && sh autoconf.sh
	cd iverilog && ./configure --prefix=$(PREFIX)
	cd iverilog && make

$(PREFIX)/bin/iverilog: iverilog/iverilog
	cd iverilog && $(SUDO) make install

# Make tar file with binaries
# Change (with -C) to $(PREFIX)/.. directory before making the tarball so we
# don't have the full path when we decompress the file, just the fosshdl folder
# Of course this would be messy if you are installing to a folder where you
# already have binaries, such as /usr/local/
blob: fosshdl.tar.gz

fosshdl.tar.gz: $(install-targets)
	tar czvf fosshdl.tar.gz -C $(PREFIX)/.. $(PREFIX)/..

# Make a docker image with the software
# Since this depends on the blob, the previous considerations apply also to
# this step
dockerimage: fosshdl.tar.gz
	docker build -t fosshdl .

# Clean

.PHONY: clean
clean:
	rm -rf $(repos)
	rm -rf osvvm_bin uvvm_bin
	rm -f env.rc

.PHONY: realclean
realclean: clean
	rm -f fosshdl.tar.gz
	rm -rf gcc-$(GCC_VERSION) gcc-$(GCC_VERSION).tar.gz

