ARG BASE_IMAGE=docker.io/ubuntu:latest

FROM ${BASE_IMAGE}
ARG SETUP_NAME=docker_base
ENV MACHINE_TYPE="container"
WORKDIR /root
COPY ./bin/ /root/temp_bin/
RUN export PATH="/root/temp_bin/:${PATH}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends sudo; \
    setup.sh ${SETUP_NAME}; \
    apt-get dist-clean; \
    rm -rf ~/.cache /var/lib/apt/lists /var/cache/apt/archives /root/temp_bin/ /usr/share/doc/*
ENTRYPOINT [ "/root/bin/run-command.sh", "-h", "local", "-c" ]
CMD ["bash"]
