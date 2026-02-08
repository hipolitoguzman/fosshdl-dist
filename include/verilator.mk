# Add targets if selected in config.mk
ifneq (,$(findstring verilator, $(selected)))
	repos += verilator
	binaries += verilator/verilator
	install-targets += $(PREFIX)/bin/verilator
endif

# Clone
verilator:
	git clone https://github.com/verilator/verilator
	cd verilator && git checkout $(VERILATOR_VERSION)

# Compile
verilator/verilator: verilator
	cd verilator && autoconf
	cd verilator && ./configure --prefix=$(PREFIX)
	cd verilator && make

# Install
$(PREFIX)/bin/verilator: verilator/verilator
	cd verilator && $(SUDO) make install
