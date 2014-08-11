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

        lagopus-vswitch.shでlagopusとtrema-edgeのlearning-switchを起動している。

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
        ...
