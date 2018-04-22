FROM alpine
MAINTAINER Frank Sachsenheim <funkyfuture@riseup.net>

VOLUME /syncthing/config /syncthing/data
CMD /start.sh
ADD start.sh /

ENV SYNCTHING_VERSION=0.14.46

RUN apk upgrade --no-cache \
 && apk add --no-cache apr apr-util ca-certificates su-exec xmlstarlet \
 && apk add --no-cache --virtual .build-deps apache2-utils curl tar \
 && cd /usr/bin \
 && cp htpasswd /tmp \
 && url="https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/syncthing-linux-arm-v${SYNCTHING_VERSION}.tar.gz" \
 && curl -L $url | tar xz --wildcards --strip-components 1 --exclude "etc/*" "*/syncthing" \
 && apk del .build-deps \
 && mv /tmp/htpasswd .
