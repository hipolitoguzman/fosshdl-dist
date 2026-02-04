# Add targets if selected in config.mk
ifneq (,$(findstring iverilog, $(selected)))
	repos += iverilog
	binaries += iverilog/iverilog
	install-targets += $(PREFIX)/bin/iverilog
endif

# Clone
iverilog:
	git clone https://github.com/steveicarus/iverilog

# Compile
iverilog/iverilog: iverilog
	cd iverilog && sh autoconf.sh
	cd iverilog && ./configure --prefix=$(PREFIX)
	cd iverilog && make -j $(NPROC) -l $(NPROC)

# Install
$(PREFIX)/bin/iverilog: iverilog/iverilog
	cd iverilog && $(SUDO) make install
