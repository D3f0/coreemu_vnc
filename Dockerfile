FROM ubuntu:17.04

ENV SCREEN_WIDTH 1280
ENV SCREEN_HEIGHT 800
ENV SCREEN_DEPTH 16
ENV PASSWORD coreemu
ENV DEBIAN_FRONTEND noninteractive


RUN cp /etc/apt/sources.list /etc/apt/sources.list.old

RUN echo "deb http://old-releases.ubuntu.com/ubuntu/ zesty main restricted universe multiverse \n \
    deb http://old-releases.ubuntu.com/ubuntu/ zesty-updates main restricted universe multiverse \n \
    deb http://old-releases.ubuntu.com/ubuntu/ zesty-security main restricted universe multiverse" > /etc/apt/sources.list

RUN apt-get upgrade  && \
    apt-get -f dist-upgrade

RUN apt-get -y update && \
    apt-get -y install iptables && \ 
    apt-get install nano vim netcat --no-install-recommends -y openbox obconf git x11vnc xvfb  wget python unzip \
        bridge-utils ebtables iproute2 iproute2 iproute libev4 libreadline6 \
        libtk-img tk8.5 dirmngr net-tools tcpdump xterm\
        feh tint2 python-numpy logrotate ca-certificates && \
        rm -rf /var/lib/apt/* 


# If we want the MDR MANET need to use the navy package
RUN wget https://downloads.pf.itd.nrl.navy.mil/ospf-manet/quagga-0.99.21mr2.2/quagga-mr_0.99.21mr2.2_amd64.deb && \
    dpkg -i quagga-mr_0.99.21mr2.2_amd64.deb && \
    rm quagga-mr_0.99.21mr2.2_amd64.deb


RUN mkdir -p ~/.vnc

RUN cd /root && git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify


RUN echo "deb http://eriberto.pro.br/core/ stretch main\ndeb-src http://eriberto.pro.br/core/ stretch main" >> /etc/apt/sources.list.d/core.list && \
    apt-key adv --keyserver pgp.surfnet.nl --recv-keys 04ebe9ef && \
    apt-get -q update && apt-get -q -y install --no-install-recommends \
        core-network core-network-daemon && apt-get -q -y install tshark \
        net-tools rox-filer \
        nano vim netcat \
        xorp bird openssh-client openssh-server isc-dhcp-server vsftpd apache2 tcpdump \
        radvd at ucarp openvpn ipsec-tools racoon traceroute mgen wireshark-gtk \
        supervisor && \
        rm -rf /var/lib/apt/*

# We have used wireshark-gtk as that has the least dependencies but CORE expects wireshark
RUN ln -s /usr/bin/wireshark-gtk /usr/bin/wireshark

# If we want the MDR MANET need to use the navy package
# RUN wget https://downloads.pf.itd.nrl.navy.mil/ospf-manet/quagga-0.99.21mr2.2/quagga-mr_0.99.21mr2.2_amd64.deb && \
#     dpkg -i quagga-mr_0.99.21mr2.2_amd64.deb && \
#     rm quagga-mr_0.99.21mr2.2_amd64.deb

RUN cd /root/noVNC && ln -sf vnc.html index.html

# Really necessary if root?
# RUN setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
ADD bg/ /root/
ADD ./config/ /root/.config/
ADD etc/supervisor/conf.d /etc/supervisor/conf.d
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Emane dependencies
RUN apt-get update -qq && apt-get --no-install-recommends -y install gcc g++ autoconf nano vim netcat automake libtool libxml2-dev libprotobuf-dev \
python-protobuf libpcap-dev libpcre3-dev uuid-dev debhelper pkg-config build-essential \
python-setuptools protobuf-compiler git dh-python python-lxml && \
rm -rf /var/lib/apt/*

# Need a patch to get EMANE to compile with GCC >7
ADD patches/gccfix.diff /root/

# Download EMANE v1.0.1 is the latest supprted
RUN cd /root/ && wget https://github.com/adjacentlink/emane/archive/v1.0.1.tar.gz && tar -xvf v1.0.1.tar.gz && \
cp gccfix.diff emane-1.0.1 && \ 
cd emane-1.0.1 && patch -p1 <gccfix.diff && \
./autogen.sh && ./configure && make deb WITHOUT_PYTHON3=1 && \
cd .debbuild && \
dpkg -i *.deb
 
# ADD extra /extra
VOLUME /root/shared
# noVNC
EXPOSE 8080
# VNC
EXPOSE 5900


ENTRYPOINT "/entrypoint.sh"
