# Makefile to make a binary distribution of the FOSS HDL/FPGA tools for teaching

include config.mk

include include/yosys.mk
include include/sby.mk
include include/ghdl.mk
include include/nvc.mk
include include/arachnepnr.mk
include include/nextpnr.mk
include include/icestorm.mk
include include/verilator.mk
include include/iverilog.mk
include include/icestudio.mk

# Put each build log in its own file. Comment to see all logs on the command
# line
# (Commented out because it does not work yet)
#DUMP_LOG = &> $@.log

# We need the .rc file that must be sourced before using the tools (we need
# this since we provide a specific version of GCC for code coverage, which
# will probably be different from the OS' GCC version)
install-targets += $(PREFIX)/env.rc

# Keep a copy of the config.mk in case we want to reproduce a specific
# configuration that works
install-targets += $(PREFIX)/config.mk

# Keep a log with all commits of all the software tools so different builds
# can be reproduced, even those who use the latest main/master
install-targets += $(PREFIX)/versions.log

# Since the included .mk files create targets, we must make 'all' the explicit
# default
.PHONY: all
.DEFAULT_GOAL := all
all: $(binaries)

.PHONY: install
install: $(install-targets)

$(PREFIX)/env.rc: env.rc
	$(SUDO) mkdir -p $(PREFIX)
	$(SUDO) cp env.rc $(PREFIX)/env.rc

$(PREFIX)/config.mk: config.mk
	$(SUDO) mkdir -p $(PREFIX)
	$(SUDO) cp config.mk $(PREFIX)/config.mk

$(PREFIX)/versions.log: versions.log
	$(SUDO) mkdir -p $(PREFIX)
	$(SUDO) cp versions.log $(PREFIX)/versions.log

# It seems that for env.rc we have to put ghdl's gcc before system gcc in order
# for code coverage to work correcly, unless we use the exact system version.
# But typically we have to use a different one because gcc 9 seems to break
# ghdl's code coverage
# Also, to be sure code coverage with gcc will work, make sure we use *our* gcc
# for linking and not the system's cc. We achieve this by setting CC to gcc, so
# our gcc is used instead of the system's cc. See
# https://github.com/ghdl/docker/issues/42 and
# https://github.com/ghdl/docker/commit/f935a57fd7c9688f982da113665d797bca15877a
# for more information
env.rc:
	echo 'export PATH=$(PREFIX)/bin:$$PATH' >> $@
	echo 'export VUNIT_SIMULATOR=ghdl' >> $@
	echo 'export GHDL_PLUGIN_MODULE=ghdl' >> $@
	echo 'export CC=gcc' >> $@

# Create a file with all commits of all the software tools so different builds
# can be reproduced
versions.log: $(repos)
	for i in $(repos); do echo -n $$i: ; cd $$i; git rev-parse HEAD ; cd ..; done > versions.log

# Check selected tools
echo-targets:
	@echo selected: $(selected)
	@echo repos: $(repos)
	@echo binaries: $(binaries)
	@echo install-targets: $(install-targets)

# Make tar file with binaries
# Change (with -C) to $(PREFIX)/.. directory before making the tarball so we
# don't have the full path when we decompress the file, just the fosshdl folder
# Of course this would be messy if you are installing to a folder where you
# already have binaries, such as /usr/local/
blob: fosshdl.tar.gz

fosshdl.tar.gz: $(install-targets)
	tar czf fosshdl.tar.gz -C $(PREFIX)/.. $(PREFIX)/..

# Make a docker image with the software
# Since this depends on the blob, the previous considerations apply also to
# this step
dockerimage: fosshdl.tar.gz
	docker build -t fosshdl .

# Clean

.PHONY: clean
clean:
	rm -rf $(repos)
	rm -f env.rc

.PHONY: realclean
realclean: clean
	rm -f fosshdl.tar.gz
	rm -rf gcc-$(GCC_VERSION) gcc-$(GCC_VERSION).tar.gz

