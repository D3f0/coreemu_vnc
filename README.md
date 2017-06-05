# CORE Network Simulator

This image is an inspirated on the work of [Stuard Mardsen](https://github.com/stuartmarsden/dockerCoreEmu) CORE EMU image and his recommendations on [Eriberto packages](http://eriberto.pro.br/core/
).

It's based, currently, on Ubuntu 17.04. You can get the udpated build at [Docker Hub](https://hub.docker.com/r/d3f0/coreemu_vnc/)

This image serves VNC and noVNC (this requires a modern web browser to be used).


## Usage

Run the image to use it:

```
docker run -d --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -p 5900:5900 -p 6080:6080 d3f0/coreemu_vnc
```

It must be run with `SYS_ADMIN` or it cannot create namespaces within the container which is needed for Core. It requires `NET_ADMIN` to make the internal networks. You can then use a VNC client and connect on `localhost:5900`.


## Sharing files
There's a volume declared as /root/shared, you can exchange files though that folder.

```
docker run -d --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v $(pwd)/shared:/root/shared -p 5900:5900 -p 6080:6080 d3f0/coreemu_vnc
```

## Password

The default password is `coreemu`.

