FROM resin/rpi-raspbian
MAINTAINER Frank Sachsenheim <funkyfuture@riseup.net>

ENV SYNCTHING_VERSION=0.14.6

RUN apt-get update \
 && apt-get install -y --no-install-recommends apache2-utils ca-certificates curl xmlstarlet \
 && curl -s https://syncthing.net/release-key.txt | apt-key add - \
 && echo "deb http://apt.syncthing.net/ syncthing release" > /etc/apt/sources.list.d/syncthing-release.list \
 && apt-get update -o Dir::Etc::sourcelist="sources.list.d/syncthing-release.list" \
 && apt-get install -y syncthing=$SYNCTHING_VERSION \
 && apt-get -y purge --auto-remove ca-certificates curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

VOLUME /syncthing/config
VOLUME /syncthing/data

ADD start.sh /
CMD /start.sh
