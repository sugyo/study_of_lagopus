FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y

### Lagopus vswitch installation w/o Intel DPDK
RUN apt-get install -y build-essential libexpat-dev libgmp-dev libncurses-dev \
	libssl-dev libpcap-dev byacc flex libreadline-dev \
	python-dev python-pastedeploy python-paste python-twisted git
WORKDIR /src
RUN git clone https://github.com/lagopus/lagopus.git
WORKDIR /src/lagopus
RUN ./configure
RUN make
RUN make install

### Install Ryu, an OpenFlow 1.3 controller
RUN apt-get install -y python-setuptools python-pip python-dev \
	libxml2-dev libxslt-dev git
WORKDIR /src
RUN git clone https://github.com/osrg/ryu.git
WORKDIR /src/ryu
RUN python ./setup.py install

RUN apt-get install -y git
WORKDIR /src
RUN git clone https://github.com/jpetazzo/pipework.git
WORKDIR /src/pipework
RUN install -m 0755 pipework /usr/local/bin

WORKDIR /
