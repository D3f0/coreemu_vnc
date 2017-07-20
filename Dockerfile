FROM ubuntu:17.04

ENV SCREEN_WIDTH 1280
ENV SCREEN_HEIGHT 800
ENV SCREEN_DEPTH 16
ENV PASSWORD coreemu
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update -qq && \
    apt-get install -y  lxde-core lxtask git x11vnc xvfb wget curl python unzip \
        bridge-utils ebtables iproute2 iproute2 iproute libev4 quagga \
        libtk-img tk8.5 dirmngr net-tools tcpdump \
        python-numpy && \
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
        python-twisted supervisor && \
        rm -rf /var/lib/apt/*

RUN cd /root/noVNC && ln -sf vnc.html index.html

# Really necessary if root?
RUN setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
RUN apt-get update \
    && apt-get install -q -y dpkg-dev python-dev && \
    easy_install pip && pip install browsepy && \
    pip install "butterfly<3" && \
    apt-get remove -q -y dpkg-dev python-dev
RUN apt-get update && apt-get install -q -y tightvncserver netcat && \
    rm -rf /var/lib/apt/cache

RUN apt-get update \
    && apt-get install -q -y nginx openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:coreemu' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


ADD extra/ /extra
ADD  vnc /root/.vnc/
RUN chmod +x /root/.vnc/xstartup
ADD ./config/ /root/.config/
ADD etc/supervisor/conf.d /etc/supervisor/conf.d
ADD etc/nginx/sites-enabled /etc/nginx/sites-enabled
ADD var/www/html /var/www/html
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV USER root
VOLUME /root/shared

EXPOSE 8080 80 22

ENTRYPOINT "/entrypoint.sh"
