SHELL=/bin/sh

all:

quickstart: run_lagopus_vswitch run_pc1 run_pc2

kill_all: kill_lagopus_vswitch kill_pc1 kill_pc2

build_lagopus_vswitch: images/lagopus_vswitch

images/lagopus_vswitch: Dockerfile
	{ docker build --no-cache -t lagopus-vswitch:ryu . && touch $@; }

rmi_lagopus_vswitch:
	{ docker rmi lagopus-vswitch:ryu; rm images/lagopus_vswitch; }

run_lagopus_vswitch: containers/lagopus_vswitch

containers/lagopus_vswitch: build_lagopus_vswitch
	{ \
		C=$$(docker run -d -v $$(pwd)/samples:/src/samples -i -t lagopus-vswitch:ryu /src/samples/lagopus-vswitch.sh) && \
		echo $$C > $@; \
		sudo pipework br1 -i eth1 $$C 0.0.0.0/0 && \
		sudo pipework br2 -i eth2 $$C 0.0.0.0/0; \
	}

kill_lagopus_vswitch:
	{ C=$$(cat containers/lagopus_vswitch) && docker kill $$C && rm containers/lagopus_vswitch; }

attach_lagopus_vswitch:
	{ C=$$(cat containers/lagopus_vswitch) && docker attach $$C; }

run_pc1: containers/pc1

containers/pc1:
	{ \
		C=$$(docker run -d -n=false -i -t ubuntu:14.04 /bin/bash); \
		echo $$C > $@; \
		sudo pipework br1 -i eth0 $$C 169.254.0.1/24; \
	}

kill_pc1:
	{ C=$$(cat containers/pc1) && docker kill $$C && rm containers/pc1; }

attach_pc1:
	{ C=$$(cat containers/pc1) && docker attach $$C; }

run_pc2: containers/pc2

containers/pc2:
	{ \
		C=$$(docker run -d -n=false -i -t ubuntu:14.04 /bin/bash); \
		echo $$C > $@; \
		sudo pipework br2 -i eth0 $$C 169.254.0.2/24; \
	}

kill_pc2:
	{ C=$$(cat containers/pc2) && docker kill $$C && rm containers/pc2; }

attach_pc2:
	{ C=$$(cat containers/pc2) && docker attach $$C; }
