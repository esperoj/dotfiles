FROM public.ecr.aws/docker/library/buildpack-deps:stable as base
ENV MACHINE_NAME="container"
WORKDIR /root
COPY bin/setup.sh /
RUN /setup.sh \
    && rm -r /var/lib/apt/lists /var/cache/apt/archives \
    && rm /setup.sh

FROM base as test
RUN --mount=type=secret,id=env \
    set -a && . /run/secrets/env && set +a \
    && ~/bin/entrypoint.sh "info.sh"

FROM base as production
ENTRYPOINT ["/root/bin/entrypoint.sh"]
