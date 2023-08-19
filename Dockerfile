#FROM kalilinux/kali-rolling
FROM ubuntu:devel
ARG PACKAGES="BASE NET BIG"
ENV MACHINE_NAME="ci"
ENV PATH="/root/.local/bin:${PATH}"
WORKDIR /root
COPY private_dot_ssh/private_known_hosts .ssh/known_hosts
COPY scripts/setup.sh scripts/pkg-install.sh .local/bin/
RUN --mount=type=ssh bash -c "source setup.sh install" \
      && apt-get autoremove -qqy \
      && rm .local/bin/setup.sh \
      && rm .local/bin/pkg-install.sh
ARG BUILD_DATE="Today"
ENV BUILD_DATE="${BUILD_DATE}"
ENTRYPOINT ["/root/.local/share/chezmoi/entrypoint.sh"]
