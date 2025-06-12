#!/bin/bash

# Avoid interactive setup in package installations such as tzdata asking for
# a geographic region
export DEBIAN_FRONTEND=noninteractive
#pkgs
apt update
apt-get install -y openssh-server curl autoconf automake bison build-essential cmake flex
apt-get install -y ninja-build libtool git unzip sudo
apt-get install -y libssl-dev libssh2-1-dev libxml2-dev uuid-dev
apt-get install -y mono-complete openjdk-11-jdk
apt-get install -y curl sshpass members chrpath rssh libcurl4-openssl-dev
apt-get install -y libcgroup-dev cgroup-bin
apt-get install -y lttng-tools liblttng-ust-dev liblttng-ctl-dev
apt-get install -y libc++1 #FabricTestHost.exe requires.

#clang 6.0
apt-get purge -y libc++-dev libc++abi-dev
apt-get install -y clang-6.0 llvm-6.0-dev # DON'T INSTALL: libc++-dev libc++abi-dev, due to #include_next in string.h

apt-get install -y golang-go go-md2man
echo 'export GOPATH=$HOME/go' >> ~/.bashrc

#build 3rd parties
apt-get install -y libgpgme-dev lvm2 libseccomp-dev libdevmapper-dev  # build cri-o
apt-get install -y libglib2.0-dev libpopt-dev              #build babeltrace
apt-get install -y libncurses5-dev libncursesw5-dev swig libedit-dev  #llvm

#build cpprest
ln -s /usr/include/locale.h /usr/include/xlocale.h


#dotnet
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get install apt-transport-https
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB3E94ADBE1229CF
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list'
apt-get update
apt-get install -y dotnet-sdk-2.1

#dotnet 2.1 RunCsc permission fix
dotnetVersion=$(dotnet --version)
run_csc_dir="/usr/share/dotnet/sdk/${dotnetVersion}/Roslyn/bincore"
if [ -f "$run_csc_dir/RunCsc" ]; then
    chmod 777 "$run_csc_dir/RunCsc"
elif [ -f "$run_csc_dir/RunCsc.sh" ]; then
    chmod 777 "$run_csc_dir/RunCsc.sh"
else
    echo "RunCsc not found under $run_csc_dir, skipping permission fix"
fi
