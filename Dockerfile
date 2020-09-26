#
# Build Container
#

ARG ALPINE_BRANCH="latest"

FROM alpine:${ALPINE_BRANCH}

RUN set -eu \
 && echo 'Start Build Container!' \
 && apk --no-cache --update add \
    alpine-sdk \
    atools \
    ca-certificates \
    ccache \
    dumb-init \
    su-exec \
    sudo \
    tzdata \
 && mkdir /abuild \
 && mkdir /apkbuild \
 && echo 'Finish Build Container!'

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

VOLUME ["/abuild", "/apkbuild"]
ENTRYPOINT ["dumb-init", "--", "docker-entrypoint.sh"]
CMD ["abuild", "-r"]
