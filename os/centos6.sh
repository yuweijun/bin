#!/bin/bash

echo "centos6.5 softwares install..."

yum install -y http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
yum update -y nss curl libcurl
yum install -y git

if [ "wget python3.6 and install" ]; then
    wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz
    tar -xzvf Python-3.6.0.tgz
    cd Python-3.6.0
    ./configure
    make
    make install
fi
