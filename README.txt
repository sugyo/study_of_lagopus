lagopus vswitchを勉強するためdockerコンテナで動かしたときのメモ。

DPDKをconfigureで指定しないとrawソケットが使われるので、rawソケットバージョンをdockerコンテナで作成。
テスト用のPCもdockerコンテナにする。

    +---------------+
    |lagopus-vswitch|
    |   コンテナ    |
    +---------------+
            |eth2 |eth1  +--------+
            |     |      |  pc1   |
            |     |      |コンテナ|
            |     |      +--------+
            |     |    eth0| 169.254.0.1/24
            |    -+--------+-
            |         br1
            |
            |            +--------+
            |            |  pc2   |
            |            |コンテナ|
            |            +--------+
            |          eth0| 169.254.0.2/24
           -+--------------+-
                      br2

lagopus-vswitchコンテナの作成
        $ docker build -t lagopus-vswitch .
        $ LAGOPUS=$(docker run -d -v $(pwd)/samples:/src/samples -i -t lagopus-vswitch /src/samples/lagopus-vswitch.sh)
        $ sudo pipework br1 -i eth1 $LAGOPUS 0.0.0.0/0
        $ sudo pipework br2 -i eth2 $LAGOPUS 0.0.0.0/0

        lagopus-vswitch.shでlagopusとryuのsimple-switchを起動している。

pc1コンテナの作成
        $ PC1=$(docker run -d -n=false -i -t ubuntu:14.04 /bin/bash)
        $ sudo pipework br1 -i eth0 $PC1 169.254.0.1/24

pc2コンテナの作成
        $ PC2=$(docker run -d -n=false -i -t ubuntu:14.04 /bin/bash)
        $ sudo pipework br2 -i eth0 $PC2 169.254.0.2/24

pc1からpc2にping
        $ docker attach $PC1
        root@xxxxxxxxxxxx: ping 169.254.0.2
        ...
        コンテナから抜ける
        コンテナからdetachするには、control-p control-q。

lagopus-vswitchコンテナでフローを確認する
        $ docker attach $LAGOPUS
        root@yyyyyyyyyyyy:lagosh
        zzzzzzzzzzzz> show flow
        Bridge: br0
         Table id: 0
          priority=1,idle_timeout=0,hard_timeout=0,flags=0,cookie=0,packet_count=53,byte_count=5082,in_port=3,eth_dst=86:60:2a:79:40:37 actions=output:2
          priority=1,idle_timeout=0,hard_timeout=0,flags=0,cookie=0,packet_count=52,byte_count=4984,in_port=2,eth_dst=b2:7c:e1:9a:f7:62 actions=output:3
          priority=0,idle_timeout=0,hard_timeout=0,flags=0,cookie=0,packet_count=14,byte_count=1012 actions=output:-3
        zzzzzzzzzzzz>

