ARG BASE_IMAGE=docker.io/ubuntu:latest

FROM ${BASE_IMAGE}
ARG SETUP_NAME=docker_base
ENV MACHINE_TYPE="container"
WORKDIR /root
RUN apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg git jq openssh-client parallel sq sudo unzip wget xz-utils; \
    apt-get dist-clean; \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives /usr/share/doc/*
COPY ./bin/ /root/temp_bin/
RUN export PATH="/root/temp_bin/:${PATH}"; \
    apt-get update; \
    setup.sh ${SETUP_NAME}; \
    apt-get dist-clean; \
    rm -rf ~/.cache /var/lib/apt/lists /var/cache/apt/archives /root/temp_bin/ /usr/share/doc/*
ENTRYPOINT [ "/root/bin/run-command.sh", "-h", "local", "-c" ]
CMD ["bash"]
