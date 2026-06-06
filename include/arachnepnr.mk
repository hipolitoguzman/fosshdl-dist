# Deprecated by nextpnr, so typically not used.

# Add targets if selected in config.mk
ifneq (,$(findstring arachne-pnr, $(selected)))
	repos += arachne-pnr
	binaries += arachne-pnr/bin/arachne-pnr
	install-targets += $(PREFIX)/bin/arachne-pnr
endif

# Clone
arachne-pnr:
	git clone https://github.com/YosysHQ/arachne-pnr
	cd arachne-pnr && git checkout $(ARACHNE-PNR_VERSION)

# Compile
arachne-pnr/bin/arachne-pnr: | arachne-pnr $(PREFIX)/bin/icepack
	make -j $(NPROC) -l $(NPROC) -C arachne-pnr PREFIX=$(PREFIX)

# Install
$(PREFIX)/bin/arachne-pnr: arachne-pnr/bin/arachne-pnr
	make -C arachne-pnr install PREFIX=$(PREFIX)
