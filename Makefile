include config.mk

targets += ghdl \
	   UVVM \
	   yosys \
	   arachne-pnr \
	   nextpnr \
	   icestorm \
	   icestudio \
	   fpga-knife

all: $(targets)

ghdl:
	git clone https://github.com/ghdl/ghdl

UVVM:
	git clone https://github.com/UVVM/UVVM

yosys:
	git clone https://github.com/YosysHQ/yosys

arachne-pnr:
	git clone https://github.com/YosysHQ/arachne-pnr

nextpnr:
	git clone https://github.com/YosysHQ/nextpnr

icestorm:
	git clone https://github.com/cliffordwolf/icestorm

icestudio:
	git clone https://github.com/FPGAwars/icestudio

fpga-knife:
	git clone https://github.com/qarlosalberto/fpga-knife



gcc-7.3.0: gcc-7.3.0.tar.gz
	tar xzvf $<
	cd gcc-7.3.0 && ./contrib/download_prerequisites

gcc-7.3.0.tar.gz:
	wget https://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz




clean:
	rm -rf $(targets)
