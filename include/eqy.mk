# Add targets if selected in config.mk
ifneq (,$(findstring eqy, $(selected)))
	repos += eqy
	binaries += eqy/src/eqy_partition.so
	install-targets += $(PREFIX)/bin/eqy
endif

# Clone
eqy:
	git clone https://github.com/YosysHQ/eqy eqy
	cd eqy && git checkout $(EQY_VERSION)

# Compile
eqy/src/eqy_partition: eqy
	make -j $(NPROC) -l $(NPROC) -C eqy PREFIX=$(PREFIX)

# Install
$(PREFIX)/bin/eqy:
	make -C eqy install PREFIX=$(PREFIX)
