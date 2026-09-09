# Add targets if selected in config.mk
ifneq (,$(findstring yosys, $(selected)))
	repos += yosys
	binaries += yosys/yosys
	install-targets += $(PREFIX)/bin/yosys
endif

# Calculate usable RAM in GB (including reclaimable buffer/cache)
RAM_GB := $(shell awk '/MemAvailable/ {print int($$2/1024/1024)}' /proc/meminfo 2>/dev/null || free -m 2>/dev/null | awk '/^Mem:/{print int($$7/1024)}')
CPU_CORES := $(shell nproc 2>/dev/null || echo 4)

# Dynamic job limit (4 GB RAM per process, minimum 1)
RAM_JOBS  := $(if $(RAM_GB),$(shell expr $(RAM_GB) / 4),$(CPU_CORES))
RAM_JOBS  := $(if $(filter 0,$(RAM_JOBS)),1,$(RAM_JOBS))
JOBS      := $(shell echo "$$(( $(RAM_JOBS) < $(CPU_CORES) ? $(RAM_JOBS) : $(CPU_CORES) ))")

# Clone
yosys:
	git clone --recursive https://github.com/YosysHQ/yosys
	cd yosys && git checkout $(YOSYS_VERSION) --recurse-submodules

# Compile
yosys/yosys: | yosys
	if [ -f yosys/CMakeLists.txt ]; then \
		echo "==> Building Yosys (CMake Flow) with $(JOBS) jobs..."; \
		cmake -B yosys/build -S yosys -DCMAKE_INSTALL_PREFIX=$(PREFIX) && \
		cmake --build yosys/build --config Release --parallel $(JOBS); \
	else \
		echo "==> Building Yosys (Legacy Flow) with $(JOBS) jobs..."; \
		make -C yosys config-clang && \
		make -j $(JOBS) -l $(JOBS) -C yosys PREFIX=$(PREFIX); \
	fi

# Install
$(PREFIX)/bin/yosys: yosys/yosys
	if [ -f yosys/CMakeLists.txt ]; then \
		$(SUDO) cmake --install yosys/build --strip; \
	else \
		$(SUDO) make -C yosys install PREFIX=$(PREFIX); \
	fi
