# Add targets if selected in config.mk
ifneq (,$(findstring yavs, $(selected)))
	repos += yavs
	binaries += yavs/target/release/yavs
	install-targets += $(PREFIX)/bin/yavs
endif

# Clone
yavs:
	git clone --recursive https://github.com/ru551n/yavs.git
	cd yavs && git checkout $(YAVS_VERSION)

# Compile
yavs/target/release/yavs: yavs
	cd yavs && \
	cargo build --locked --release -p yavs --features clift

# Install
$(PREFIX)/bin/yavs: yavs/target/release/yavs
	install -Dm755 yavs/target/release/yavs $(PREFIX)/bin/yavs
	#cd yavs && \
	#cargo install --locked --path crates/yavs --features clift --root $(PREFIX)
