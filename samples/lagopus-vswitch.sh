#!/bin/sh -

install -m 644 /src/samples/lagopus.conf /usr/local/etc/lagopus

pipework --wait -i eth1
pipework --wait -i eth2

ryu-manager --pid-file /var/run/simple_switch_13.pid  --nouse-stderr --log-file /tmp/simple_switch_13.log /src/ryu/ryu/app/simple_switch_13.py &
lagopus -d -l /tmp/lagopus.log -- -- -p3 &

#lagosh
bash
