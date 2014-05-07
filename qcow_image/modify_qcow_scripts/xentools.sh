#!/bin/bash

wget http://boot.rackspace.com/files/xentools/xs-tools-6.2.0.iso

mkdir xentmp
mount -o loop xs-tools-6.2.0.iso xentmp
pushd xentmp/Linux

# Force install (as 12.04 even though this is 14.04)
# since xenserver tools only supports upto ubuntu 12.04
os_minorver="04" ./install.sh -d "ubuntu" -m "12" -n

popd

umount -l xentmp
rm -rf xentmp
