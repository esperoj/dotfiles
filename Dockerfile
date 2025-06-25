ARG BASE_IMAGE=docker.io/pypy:3.11

FROM ${BASE_IMAGE}
ENV MACHINE_TYPE="container"
ARG SETUP_NAME=docker_base
WORKDIR /root
COPY ./Makefile .
RUN set -eux; \
    apt-get update -yqq; \
    make -j "${SETUP_NAME}"; \
    make -j clean;
ENTRYPOINT ["/bin/bash"]
