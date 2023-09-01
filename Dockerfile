FROM public.ecr.aws/docker/library/buildpack-deps:stable as base
ENV MACHINE_NAME="container"
WORKDIR /root
COPY bin/install-dotfiles.sh /
RUN /install-dotfiles.sh \
    && ~/bin/setup.sh \
    && rm -r /var/lib/apt/lists /var/cache/apt/archives /install-dotfiles.sh

FROM base as test
RUN --mount=type=secret,id=env \
    set -a && . /run/secrets/env && set +a \
    && ~/bin/entrypoint.sh "info.sh" \
    && echo "$(date --utc)" > /root/build-date.txt

FROM base as final
COPY --from=test /root/build-date.txt .
ENTRYPOINT ["/root/bin/entrypoint.sh"]
