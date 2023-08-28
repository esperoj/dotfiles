FROM public.ecr.aws/docker/library/buildpack-deps:stable
ENV MACHINE_NAME="container"
WORKDIR /root
COPY bin/setup.sh /
RUN /setup.sh \
    && rm -r /var/lib/apt/lists /var/cache/apt/archives \
    && rm /setup.sh
ENTRYPOINT ["/root/.local/share/chezmoi/bin/entrypoint.sh"]
