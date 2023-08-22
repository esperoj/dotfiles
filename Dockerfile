FROM buildpack-deps:stable
ARG PACKAGES="BASE NET BIG"
ARG BUILD_DATE="Today"
ENV BUILD_DATE="${BUILD_DATE}"
ENV MACHINE_NAME="ci"
WORKDIR /root/.local/share/chezmoi/bin
RUN git clone https://codeberg.org/esperoj/dotfiles.git . \
    && ./setup.sh \
		&& sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "/root/.local/bin" \
		&& rm -rf /var/lib/apt/lists/*
WORKDIR /root
ENTRYPOINT ["/root/.local/share/chezmoi/bin/entrypoint.sh"]
