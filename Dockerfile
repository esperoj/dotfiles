FROM kalilinux/kali-rolling
ARG PACKAGES="ALL"
ARG MACHINE_NAME="ci"
ENV PATH="/root/.local/bin:${PATH}"
WORKDIR /root
COPY private_dot_ssh/private_known_hosts .ssh/known_hosts
COPY scripts/setup.sh scripts/pkg-install.sh .local/bin/
RUN echo "$PATH" && ls -al "${HOME}" && ls -al "${HOME}/.ssh"
RUN --mount=type=ssh bash -c "source setup.sh install" \
      && apt-get autoremove -qqy \
      && rm .local/bin/{setup.sh,pkg-install.sh}
ENTRYPOINT ["${HOME}/.local/share/chezmoi/entrypoint.sh"]
