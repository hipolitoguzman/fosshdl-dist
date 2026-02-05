# Add targets if selected in config.mk
ifneq (,$(findstring SymbiYosys, $(selected)))
	repos += symbiyosys
	repos += yices2
	repos += z3
	#repos += super-prove-build
	repos += extavy
	repos += boolector
	repos += rIC3
	install-targets += $(PREFIX)/bin/sby
	install-targets += $(PREFIX)/bin/yices
	install-targets += $(PREFIX)/bin/z3
	#install-targets += $(PREFIX)/bin/suprove
	install-targets += $(PREFIX)/bin/avy
	install-targets += $(PREFIX)/bin/boolector
endif

# Clone sby and solvers

symbiyosys:
	git clone https://github.com/YosysHQ/SymbiYosys symbiyosys

yices2:
	git clone https://github.com/SRI-CSL/yices2.git

z3:
	git clone https://github.com/Z3Prover/z3.git
	cd z3 && git checkout $(Z3_VERSION)

super-prove-build:
	git clone --recursive https://github.com/sterin/super-prove-build

# Install from cargo instead of from git, but anyways cargo compiles it
rIC3:
	#git clone --recurse-submodules https://github.com/gipsyh/rIC3
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	python3 -m venv ric3_venv
	. ric3_venv/bin/activate && pip3 install meson
	. ric3_venv/bin/activate && . $(HOME)/.cargo/env && rustup default nightly && cargo install --root=$(PREFIX) rIC3

# For avy to compile with gcc 9.3.0 (the one in ubuntu 20.04) we need to apply
# this patch from Michael Jorgensen:
# https://github.com/MJoergen/formal/blob/main/INSTALL.md
# And this third change:
# https://github.com/YosysHQ/fpga-toolchain/issues/57
# We will just perform a substitution in the affected files
extavy:
	git clone https://bitbucket.org/arieg/extavy.git
	cd extavy && git submodule update --init
	sed -i 's/bool isSolved () { return m_Trivial || m_State || !m_State; }/bool isSolved () { return bool{m_Trivial || m_State || !m_State}; }/' extavy/avy/src/ItpGlucose.h
	sed -i 's/return tobool (m_pSat->modelValue(x));/boost::logic::tribool y = tobool (m_pSat->modelValue(x));\nreturn bool{y};/' extavy/avy/src/ItpGlucose.h
	sed -i 's/bool isSolved () { return m_Trivial || m_State || !m_State; }/bool isSolved () { return bool{m_Trivial || m_State || !m_State}; }/' extavy/avy/src/ItpMinisat.h

boolector:
	git clone https://github.com/boolector/boolector

# Compile and install symbiyosys. This is all done in one step since it is all
# grouped into a single step in symbiosys' Makefile
$(PREFIX)/bin/sby: symbiyosys
	$(SUDO) make -j $(NPROC) -l $(NPROC) -C symbiyosys PREFIX=$(PREFIX) install

# Compile and install the solvers that SymbiYosys can use
# Instructions came from here:
# https://yosyshq.readthedocs.io/projects/sby/en/latest/install.html#prerequisites
# TODO: check for correctness, add to binaries list
$(PREFIX)/bin/yices: yices2
	cd yices2 && \
	autoconf && \
	./configure --prefix=$(PREFIX) && \
	make -j $(NPROC) -l $(NPROC) && \
	$(SUDO) make install

$(PREFIX)/bin/z3: z3
	cd z3 && \
	python3 scripts/mk_make.py --prefix=$(PREFIX) && \
	cd build && \
	make -j $(NPROC) -l $(NPROC) && \
	$(SUDO) make install

$(PREFIX)/super_prove/bin/super_prove.sh: | super-prove-build
	cd super-prove-build && mkdir -p build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX) -G Ninja .. && \
	ninja && \
	ninja package && \
	cp super_prove-*-Release.tar.gz super_prove.tar.gz && \
	$(SUDO) tar -C $(PREFIX) -x --file super_prove.tar.gz

$(PREFIX)/bin/suprove: $(PREFIX)/super_prove/bin/super_prove.sh
	echo '#!/bin/bash' > $@
	echo 'tool=super_prove; if [ "$$1" != "$${1#+}" ]; then tool="$${1#+}"; shift; fi' >> $@
	echo 'exec $(PREFIX)/super_prove/bin/$${tool}.sh "$$@"' >> $@
	$(SUDO) chmod +x $@

$(PREFIX)/bin/avy: extavy
	cd extavy && mkdir -p build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX) -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .. && \
	make -j $(NPROC) -l $(NPROC) && \
	pwd && \
	$(SUDO) cp avy/src/avy $(PREFIX)/bin && \
	$(SUDO) cp avy/src/avybmc $(PREFIX)/bin

$(PREFIX)/bin/boolector: boolector
	cd boolector && \
	./contrib/setup-btor2tools.sh && \
	./contrib/setup-lingeling.sh && \
	./configure.sh --prefix $(PREFIX) && \
	make -j $(NPROC) -l $(NPROC) -C build && \
	$(SUDO) cp build/bin/boolector $(PREFIX)/bin/ && \
	$(SUDO) cp build/bin/btor* $(PREFIX)/bin/ && \
	$(SUDO) cp deps/btor2tools/build/bin/btorsim $(PREFIX)/bin/

