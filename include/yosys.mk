# Add targets if selected in config.mk
ifneq (,$(findstring yosys, $(selected)))
	repos += yosys
	binaries += yosys/yosys
	install-targets += $(PREFIX)/bin/yosys
endif

# Clone
yosys:
	git clone --recursive https://github.com/YosysHQ/yosys
	cd yosys && git checkout $(YOSYS_VERSION)

# Compile
yosys/yosys: | yosys
	make -C yosys config-clang
	make -j $(NPROC) -l $(NPROC) -C yosys PREFIX=$(PREFIX)

# Install
ifneq ($(USE_SYMBIOTIC),yes)
$(PREFIX)/bin/yosys: yosys/yosys
	make -C yosys install PREFIX=$(PREFIX)
endif
