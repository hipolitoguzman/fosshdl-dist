# Add targets if selected in config.mk
ifneq (,$(findstring icestudio, $(selected)))
	repos += icestudio
	install-targets += $(PREFIX)/bin/icestudio
endif

# Clone
icestudio: $(PREFIX)/icestudio

$(PREFIX)/icestudio:
	git clone https://github.com/FPGAwars/icestudio $(PREFIX)/icestudio
	cd icestudio && git checkout $(ICESTUDIO_VERSION)

# Install
$(PREFIX)/bin/icestudio: $(PREFIX)/icestudio
	cd $(PREFIX)/icestudio && npm install
	echo "cd $(PREFIX)/bin/icestudio && npm start" >> $(PREFIX)/bin/icestudio
	chmod +x $(PREFIX)/bin/icestudio
