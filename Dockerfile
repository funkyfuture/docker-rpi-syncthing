FROM container4armhf/armhf-alpine:edge
MAINTAINER Frank Sachsenheim <funkyfuture@riseup.net>

ENV SYNCTHING_VERSION=0.14.5

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
 && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
 && apk add --no-cache apache2-utils bash syncthing xmlstarlet

VOLUME /syncthing/config
VOLUME /syncthing/data

ADD start.sh /
CMD /start.sh
