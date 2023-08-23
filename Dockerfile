FROM buildpack-deps:stable
ARG PACKAGES="BASE NET BIG"
ARG BUILD_DATE="Today"
ENV BUILD_DATE="${BUILD_DATE}"
ENV MACHINE_NAME="ci"
WORKDIR /root/.local/share/chezmoi
RUN curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/install-dotfiles.sh | bash \
    && ./bin/setup.sh \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /root
ENTRYPOINT ["/root/.local/share/chezmoi/bin/entrypoint.sh"]
