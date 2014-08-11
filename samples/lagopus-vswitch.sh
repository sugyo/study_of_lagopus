#!/bin/sh -

install -m 644 /src/samples/lagopus.conf /usr/local/etc/lagopus/

pipework --wait -i eth1
pipework --wait -i eth2

cd /home/trema/trema-edge
sudo -u trema ./trema run src/examples/learning_switch/learning-switch.rb -d
lagopus -d -l /tmp/lagopus.log -- -- -p3 &

#lagosh
bash
