FROM buildpack-deps:stable
ENV MACHINE_NAME="container"
WORKDIR /root
RUN apt-get update -qqy \
    && apt-get install -qqy --no-install-recommends parallel python3-full python3-pip sudo zsh
COPY bin/install-dotfiles.sh /
RUN /install-dotfiles.sh \
    && ~/bin/setup.sh \
    && rm -r /var/lib/apt/lists /var/cache/apt/archives /install-dotfiles.sh
ENTRYPOINT ["/root/bin/entrypoint.sh"]
