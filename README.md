# RPi-Syncthing

This is a [Docker](https://www.docker.com) image targeting
[Raspberry Pi](https://www.raspberrypi.org) hosts containing
[Syncthing](https://syncthing.net) which describes itself:

> Syncthing replaces proprietary sync and cloud services with something open,
> trustworthy and decentralized. Your data is your data alone and you deserve
> to choose where it is stored, if it is shared with some third party and how
> it's transmitted over the Internet.

[What's the current `latest` version?](https://github.com/funkyfuture/docker-rpi-syncthing/blob/master/Dockerfile#L8)


It is supposed to use the host's network stack, which is a **potential security
risk**.

For a suitable host system check out [Hypriot OS](http://blog.hypriot.com/downloads/)!

Contributions are welcome.


## Pull

    docker pull funkyfuture/rpi-syncthing

## Build

    git clone https://github.com/funkyfuture/docker-rpi-syncthing
    docker build -t funkyfuture/rpi-syncthing docker-rpi-syncthing

## Run

Here's an example configuration that is suited to manage an instance with
[`docker-compose`](https://docs.docker.com/compose/):

```yaml
version: '2'

services:
  client:
    image: funkyfuture/rpi-syncthing
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./config:/syncthing/config
      - ./data:/syncthing/data
    environment:
      - GUI_USERNAME=ziggy
      - GUI_PASSWORD_PLAIN=stardust
```

For those eager to quickly test this image:

    docker run --rm --network=host funkyfuture/rpi-syncthing

## Configuration

The numeric user and group id of the user running the client are set with the
environment variables `UID` and `GID`. Both default to `1000`. This affects the
ownership of the stored data in `/syncthing` and `$CONFIG_DIR`.

You can pass these environment variables to configure the client:

- `CONFIG_DIR` (default: `/syncthing/config`)
- `GUI_ADDRESS` (default: `[::]:8384`)
- `GUI_APIKEY`
- `GUI_ENABLED` (default: `true`)
- `GUI_PASSWORD_PLAIN`
- `GUI_PASSWORD_BCRYPT` (takes precedence over `..._PLAIN`)
- `GUI_TLS` (default: `false`)
- `GUI_USERNAME`

## Further customization

To further customize the configuration you can provide your own
`$CONFIG_DIR/config.xml` to the container. Note that the configuration values
resp. their defaults above will be applied on it (but this is going to be more
sensible at some point).

You may also add a `/pre-launch.sh` that will be run (by `source`ing) after
the configuration values have been applied. For convenient xml-manipulation
you can use `xmlstarlet`, see `start.sh` for examples and a wrapper function.
The user context at this point is still `root`, the designated user context
to run `syncthing` is available as `$UID`, `$GID`, `$USER_NAME` and
`$GROUP_NAME`.

## Resources

###### Docker Hub repository

https://registry.hub.docker.com/u/funkyfuture/rpi-syncthing/

###### Source repository

https://github.com/funkyfuture/docker-rpi-syncthing

###### Syncthing configuration docs

https://docs.syncthing.net/users/config.html

###### xmlstarlet documentation

http://xmlstar.sourceforge.net/doc/UG/
