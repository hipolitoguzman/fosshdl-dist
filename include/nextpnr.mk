# Add targets if selected in config.mk
ifneq (,$(findstring nextpnr, $(selected)))
	repos += nextpnr
	binaries += nextpnr/nextpnr-ice40
	install-targets += $(PREFIX)/bin/nextpnr-ice40
endif

# Clone
nextpnr:
	git clone --recursive https://github.com/YosysHQ/nextpnr
	cd nextpnr && git checkout $(NEXTPNR_VERSION)

# Compile
nextpnr/nextpnr-ice40: $(PREFIX)/bin/icepack | nextpnr $(PREFIX)/bin/icepack
	cd nextpnr && \
	mkdir -p build && \
	cd build && \
	cmake .. -DARCH=ice40 -DBUILD_GUI=ON -DICESTORM_INSTALL_PREFIX=$(PREFIX) -DCMAKE_INSTALL_PREFIX=$(PREFIX) && \
	make -j $(NPROC) -l $(NPROC)

# Install
# I had to make a quick hack here and add the | because the installation seems
# to make a floor() operation on the 'modified' date of the installed
# executable, causing the target to be be always outdated 
$(PREFIX)/bin/nextpnr-ice40: | nextpnr/nextpnr-ice40
	cd nextpnr/build && \
	$(SUDO) make install
