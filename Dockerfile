FROM public.ecr.aws/docker/library/buildpack-deps:stable
ARG PACKAGES="BASE NET BIG"
ARG BUILD_DATE="Today"
ENV BUILD_DATE="${BUILD_DATE}"
ENV MACHINE_NAME="ci"
WORKDIR /root
COPY bin/setup.sh /
RUN /setup.sh \
    && rm -rf /var/lib/apt/lists/* \
    && rm /setup.sh
ENTRYPOINT ["/root/.local/share/chezmoi/bin/entrypoint.sh"]
