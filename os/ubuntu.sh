#!/bin/bash

sudo apt install xclip

git clone https://github.com/yuweijun/hsdis

cd hsdis
tar -zxvf binutils-2.26.tar.gz
make BINUTILS=binutils-2.26 ARCH=amd64

sudo cp build/linux-amd64/hsdis-amd64.so /usr/lib/jvm/java-8-oracle/jre/lib/amd64/server/

