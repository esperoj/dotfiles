ARG BASE_IMAGE=docker.io/ubuntu:rolling

FROM ${BASE_IMAGE}
ARG SETUP_NAME=docker_base
ENV MACHINE_TYPE="container"
WORKDIR /root
COPY ./bin/ /root/temp_bin/
RUN export PATH="/root/temp_bin/:${PATH}"; \
    apt-get update -q=2; \
    setup.sh ${SETUP_NAME}; \
    apt-get -q=2 dist-clean; \
    rm -rf ~/.cache /var/lib/apt/lists /var/cache/apt/archives /root/temp_bin/ /usr/share/doc/*
ENTRYPOINT [ "/root/bin/run-command.sh", "-h", "local", "-c" ]
CMD ["bash"]
