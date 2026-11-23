ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ARG BASE_IMAGE
ENV DEBIAN_FRONTEND=noninteractive

COPY scripts/ /tmp/scripts/

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential tar ca-certificates && \
    if [ "$BASE_IMAGE" = "ubuntu:22.04" ]; then \
        sh /tmp/scripts/install_cmake_old_distros.sh; \
    fi && \
    sh /tmp/scripts/install_deps_${BASE_IMAGE}.sh && \
    rm -rf /tmp/scripts /var/lib/apt/lists/*
