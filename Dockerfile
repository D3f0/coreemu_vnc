FROM ubuntu:17.04

ENV SCREEN_WIDTH 1280
ENV SCREEN_HEIGHT 800
ENV SCREEN_DEPTH 16
ENV PASSWORD coreemu
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update -qq && \
    apt-get install -y openbox obconf git x11vnc xvfb  wget python unzip \
        bridge-utils ebtables iproute2 iproute2 iproute libev4 quagga \
        libtk-img tk8.5 dirmngr net-tools tcpdump \
        feh tint2 python-numpy && \
        rm -rf /var/lib/apt/*

RUN mkdir -p ~/.vnc

RUN cd /root && git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify


RUN echo "deb http://eriberto.pro.br/core/ stretch main\ndeb-src http://eriberto.pro.br/core/ stretch main" >> /etc/apt/sources.list.d/core.list && \
    apt-key adv --keyserver pgp.surfnet.nl --recv-keys 04ebe9ef && \
    apt-get -q update && apt-get -q -y install \
        core-network tshark \
        net-tools rox-filer \
        quagga xorp bird openssh-client openssh-server isc-dhcp-server vsftpd apache2 tcpdump \
        radvd at ucarp openvpn ipsec-tools racoon traceroute mgen tshark \
        supervisor && \
        rm -rf /var/lib/apt/*

# Really necessary if root?
RUN setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
ADD bg/ /root/
ADD ./config/ /root/.config/
ADD etc/supervisor/conf.d /etc/supervisor/conf.d
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /root/shared
# noVNC
EXPOSE 80
# VNC
EXPOSE 5900

#ADD https://github.com/krallin/tini/releases/download/v0.14.0/tini-amd64 /bin/tini
#RUN chmod +x /bin/tini

ENTRYPOINT "/entrypoint.sh"
