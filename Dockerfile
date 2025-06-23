ARG BASE_IMAGE=docker.io/pypy:3.11
ARG SETUP_NAME=docker_base

FROM ${BASE_IMAGE}
ENV MACHINE_TYPE="container"
WORKDIR /root
COPY ./Makefile .
RUN export SETUP_NAME; \
    make -j "${SETUP_NAME}"; \
    make -j clean;
ENTRYPOINT ["/bin/bash"]