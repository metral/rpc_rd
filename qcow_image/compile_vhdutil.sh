#!/bin/bash

# Update & install deps
sudo apt-get update
sudo apt-get install python-dev gettext bin86 bcc iasl uuid e2fsprogs uuid-dev libncurses5-dev pkg-config libglib2.0-dev libaio-dev libyajl-dev gcc-multilib libpixman-1-dev faketime libssl-dev -y

# Get latest Xen source
wget -q http://bits.xensource.com/oss-xen/release/4.4.0/xen-4.4.0.tar.gz
tar -xzf xen-*.tar.gz
cd xen-*/tools/

# Apply patch for vhd-util as prescribed by:
# http://blogs.citrix.com/2012/10/04/convert-a-raw-image-to-xenserver-vhd/
wget https://github.com/citrix-openstack/xenserver-utils/raw/master/blktap2.patch -qO - | patch -p0

# Complie patched vhd-util
CPUS=`cat /proc/cpuinfo | grep processor | wc -l`

./configure --disable-monitors --disable-ocamltools --disable-rombios --disable-seabios
make -j$CPUS
