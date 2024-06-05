FROM buildpack-deps:stable
ENV MACHINE_NAME="container"
WORKDIR /root
COPY bin/install.sh /
RUN apt-get update -qqy \
    && apt-get install -qqy --no-install-recommends parallel sudo zsh jq \
    && /install.sh dotfiles \
    && ~/bin/setup.sh \
    && rm -rf ~/.cache /var/lib/apt/lists /var/cache/apt/archives /install.sh
ENTRYPOINT ["/root/bin/entrypoint.sh"]
