# Add targets if selected in config.mk
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

# Clone

ghdl:
	git clone https://github.com/ghdl/ghdl
	cd ghdl && git checkout $(GHDL_VERSION)

ghdl-yosys-plugin:
	git clone https://github.com/ghdl/ghdl-yosys-plugin
	cd ghdl-yosys-plugin && git checkout $(GHDLSYNTH_VERSION)

# Download and untar GCC (needed for GHDL)
gcc-$(GCC_VERSION): gcc-$(GCC_VERSION).tar.gz
	tar xzf $<
	cd $@ && sed -i 's/ftp/http/' contrib/download_prerequisites && ./contrib/download_prerequisites

gcc-$(GCC_VERSION).tar.gz:
	wget https://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz

# Compile

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
	make -j $(NPROC) -l $(NPROC)

# GHDL must be installed to compile ghdllib
ghdl/build/grt/libgrt.a: $(PREFIX)/bin/ghdl
	cd ghdl/build && \
	make -j $(NPROC) -l $(NPROC) ghdllib

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

# Compile and install ghdl-yosys-plugin
ghdl-yosys-plugin/ghdl.so: ghdl-yosys-plugin $(PREFIX)/bin/ghdl $(PREFIX)/bin/yosys $(PREFIX)/lib/ghdl/libgrt.a $(PREFIX)/env.rc
	cd ghdl-yosys-plugin && \
	. $(PREFIX)/env.rc && \
	make -j $(NPROC) -l $(NPROC)

$(PREFIX)/share/yosys/plugins/ghdl.so: ghdl-yosys-plugin/ghdl.so
	cd ghdl-yosys-plugin && \
	. $(PREFIX)/env.rc && \
	make install
