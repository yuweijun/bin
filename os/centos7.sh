#!/bin/bash

echo "centos7 softwares install..."

yum install -y http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm
yum update -y nss curl libcurl
yum install -y git
yum install -y tmux mycli the_silver_searcher python-pygments

