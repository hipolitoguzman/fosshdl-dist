# Add targets if selected in config.mk
ifneq (,$(findstring icestorm, $(selected)))
	repos += icestorm
	binaries += icestorm/icepack/icepack
	install-targets += $(PREFIX)/bin/icepack
endif

# Clone
icestorm:
	git clone https://github.com/cliffordwolf/icestorm

# Compile
icestorm/icepack/icepack: | icestorm
	make -j $(NPROC) -l $(NPROC) -C icestorm

# Install
$(PREFIX)/bin/icepack: icestorm/icepack/icepack
	$(SUDO) make -C icestorm install PREFIX=$(PREFIX)
