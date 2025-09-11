# Base image to be used
FROM ubuntu:22.04

# Metadata for this image
LABEL \
  maintainer="Hipólito Guzmán-Miranda <hguzman@us.es>"

# Install dependencies
RUN set -ex ; \
  export DEBIAN_FRONTEND="noninteractive" ; \
  # Mandatory update
  apt-get -y update ; \
  # Install software we need
  apt install -y git make tar gcc lcov gcovr octave gnat zlib1g-dev gtkwave libcanberra-gtk-module libboost-all-dev libftdi1 ; \
  apt install -y g++ python3 python3-dev python3-pip; \
  # Apt cleanup
  apt-get -y clean ; \
  apt-get -y autoclean ; \
  apt-get -y autoremove ; \
  rm -rf /var/lib/apt/lists/* ;

  # Create default user and group
#RUN \
#  # Add default group
#  addgroup --gid 1000 "group"; \
#  # Add default user
#  adduser \
#    --home "/home/salas" \
#    --gecos "default user" \
#    --shell "/bin/bash" \
#    --uid 1000 \
#    --gid 1000 \
#    --disabled-password \
#    "salas" ;

# Since 23.04, Ubuntu has a default 'ubuntu' user, so no need to create it
RUN usermod -l salas ubuntu

# Copy the tarball with the software
COPY fosshdl.tar.gz /home/salas/fosshdl.tar.gz

# Install already-compiled tools and remove the tarball
RUN \
  cd /home/salas ; \
  tar xzf fosshdl.tar.gz ; \
  echo "source /home/salas/fosshdl/env.rc" >> /home/salas/.bashrc ; \
  chown salas: /home/salas/.bashrc ; \
  chown -R salas: /home/salas/fosshdl ; \
  rm /home/salas/fosshdl.tar.gz ;

# Install tools available in python-pip, and also a yosys dependence (Click)
# TODO: maybe uninstall python3-pip in this step? But probably we would need to
# do an apt update before
RUN \
  pip3 install Click ; \
  pip3 install vunit-hdl ; \
  pip3 install matplotlib ; \
  pip3 install numpy ; \
  pip3 install oct2py ; \
  pip3 install --upgrade amaranth[builtin-yosys] ; \
  pip3 install cocotb ;

# Solve weird issue which makes nextpnr not find libQt5Core sometimes
#
# As far as I know, this happens when running the docker image under specific host OSes
#   - Debian 11: doesn't fail
#   - Centos 8.5.2111: doesn't fail
#   - Centos 7.9.2009 (Core): fails
# https://stackoverflow.com/a/65564226
RUN strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5   

# In docker, we store persistent data in volumes
VOLUME [ "/home/salas/workdir" ]

# CMD defines default commands and/or parameters
# ENTRYPOINT is preferred when you want to define a container with a specific
# executable. You cannot override an ENTRYPOINT unless you add the --entrypoint
# flag

# Default command is an echo inside a bash shell
CMD [ "/bin/bash", "-c", "echo \"Hello! I'm running on '$(hostname)'!\" && \
  echo \"Free and Open Source Software to work with VHDL and FPGAs\" && \
  echo \"To launch this image interactively, do: \" && \
  echo '  docker run --rm -it --volume \"$(pwd):/home/salas/workdir\" --user \"$(id -u)\":\"$(id -g)\" <imagename> bash '" ]

