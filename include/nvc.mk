# Add targets if selected in config.mk
ifneq (,$(findstring nvc, $(selected)))
	repos += nvc
	binaries += nvc/build/bin/nvc
	install-targets += $(PREFIX)/bin/nvc
endif

# Clone
nvc:
	git clone https://github.com/nickg/nvc
	cd nvc && git checkout $(NVC_VERSION)

# Compile
nvc/build/bin/nvc: nvc
	cd nvc && ./autogen.sh && mkdir -p build && cd build && ../configure --prefix=$(PREFIX) && make

# Install
$(PREFIX)/bin/nvc: nvc/build/bin/nvc
	cd nvc/build && $(SUDO) make install
