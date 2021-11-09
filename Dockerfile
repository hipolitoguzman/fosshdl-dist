# Base image to be used
FROM ubuntu:20.04

# Metadata for this image
LABEL \
  maintainer="Hipólito Guzmán-Miranda <hguzman@us.es>"

# Install dependencies
RUN set -ex ; \
  export DEBIAN_FRONTEND="noninteractive" ; \
  # Mandatory update
  apt-get -y update ; \
  # Install software we need
  apt install -y git make gcc lcov gcovr gnat zlib1g-dev gtkwave libcanberra-gtk-module libboost-all-dev libftdi1 ; \
  # Apt cleanup
  apt-get -y clean ; \
  apt-get -y autoclean ; \
  apt-get -y autoremove ; \
  rm -rf /var/lib/apt/lists/* ;

  # Create default user and group
RUN \
  # Add default group
  addgroup --gid 1000 "group"; \
  # Add default user
  adduser \
    --home "/home/salas" \
    --gecos "default user" \
    --shell "/bin/bash" \
    --uid 1000 \
    --gid 1000 \
    --disabled-password \
    "salas" ;

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

# In docker, we store persistent data in volumes
VOLUME [ "/home/salas/workdir" ]

# CMD defines default commands and/or parameters
# ENTRYPOINT is preferred when you want to define a container with a specific
# executable. You cannot override an ENTRYPOINT unless you add the --entrypoint
# flag

# Default command is an echo inside a bash shell
CMD [ "/bin/bash", "-c", "echo \"Hello! I'm running on '$(hostname)'!\"" ]

