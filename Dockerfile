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

### Install Trema-edge, an OpenFlow 1.3 controller
RUN apt-get install -y gcc make git ruby2.0 ruby2.0-dev libpcap-dev libsqlite3-dev
RUN ln -s /usr/include/x86_64-linux-gnu/ruby-2.0.0 /usr/include/ruby-2.0.0/x86_64-linux-gnu
RUN ln -s /usr/bin/ruby2.0 /usr/local/bin/ruby
RUN ln -s /usr/bin/gem2.0 /usr/local/bin/gem
RUN useradd -m -s /bin/bash trema
RUN echo 'trema:trema' | chpasswd
RUN echo 'trema ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/trema
USER trema
WORKDIR /home/trema
RUN git clone https://github.com/trema/trema-edge.git
WORKDIR /home/trema/trema-edge
ENV HOME /home/trema
RUN sudo gem install bundler
RUN bundle
RUN rake
USER root
ENV HOME /

RUN apt-get install -y git
WORKDIR /src
RUN git clone https://github.com/jpetazzo/pipework.git
WORKDIR /src/pipework
RUN install -m 0755 pipework /usr/local/bin

WORKDIR /
