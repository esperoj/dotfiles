ARG BASE_IMAGE=docker.io/pypy:3.11
ARG SETUP_NAME=docker_base

FROM ${BASE_IMAGE}
ENV MACHINE_TYPE="container"
ENV SETUP_NAME=${SETUP_NAME}
WORKDIR /root
COPY ./Makefile .
RUN set -eux; \
    apt-get update -yqq; \
    make -j "${SETUP_NAME}"; \
    make -j clean;
ENTRYPOINT ["/bin/bash"]
