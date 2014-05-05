#!/bin/bash

sudo apt-get update
sudo apt-get install python-dev gettext bin86 bcc iasl uuid e2fsprogs uuid-dev libncurses5-dev pkg-config libglib2.0-dev libaio-dev libyajl-dev gcc-multilib libpixman-1-dev faketime libssl-dev -y

wget -q http://bits.xensource.com/oss-xen/release/4.4.0/xen-4.4.0.tar.gz
tar -xzf xen-*.tar.gz
cd xen-*/tools/
wget https://github.com/citrix-openstack/xenserver-utils/raw/master/blktap2.patch -qO - | patch -p0
./configure --disable-monitors --disable-ocamltools --disable-rombios --disable-seabios

CPUS=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$CPUS
