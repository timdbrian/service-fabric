#!/bin/bash

# Avoid interactive setup in package installations such as tzdata asking for
# a geographic region
export DEBIAN_FRONTEND=noninteractive

#update
apt update

apt-get install -y openssh-server curl locales

#pkgs
apt-get install -y build-essential git unzip sudo
apt-get install -y cmake ninja-build clang llvm libc++1 libc++-dev libxml2-dev libssh2-1-dev
apt-get install -y libssl-dev uuid-dev mono-complete
apt-get install -y sshpass members chrpath rssh libcurl4-openssl-dev
apt-get install -y libcgroup-dev cgroup-bin
apt-get install -y lttng-tools liblttng-ust-dev liblttng-ctl-dev lttng-modules-dkms
apt-get install -y libcurl4-openssl-dev

apt-get install -y golang go-md2man
echo 'export GOPATH=$HOME/go' >> ~/.bashrc

#build 3rd parties
apt-get install -y libgpgme-dev lvm2 libseccomp-dev libdevmapper-dev  # build cri-o
apt-get install -y libglib2.0-dev libpopt-dev              #build babeltrace
apt-get install -y libncurses5-dev libncursesw5-dev swig libedit-dev  #llvm

# Install .NET sdk and runtime for building and running managed code of product.
apt-get install -y apt-transport-https ca-certificates  apt-utils && \
    sh -c 'curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg' && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-get update && \
    apt-get install -y dotnet-sdk-2.0.3 && \
apt-get install -y dotnet-runtime-2.0.7
