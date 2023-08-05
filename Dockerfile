FROM kalilinux/kali-rolling
ARG PACKAGES="ALL"
ARG MACHINE_NAME="ci"
ENV PATH="${HOME}/.local/bin:${PATH}"
WORKDIR "${HOME}"
COPY scripts/setup.sh scripts/pkg-install.sh .local/bin/
RUN --mount=type=ssh setup.sh install \
      && apt-get autoremove -qqy \
      && rm .local/bin/{setup.sh,pkg-install.sh}
ENTRYPOINT ["${HOME}/.local/share/chezmoi/entrypoint.sh"]
