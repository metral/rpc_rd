#!/bin/bash

wget http://boot.rackspace.com/files/xentools/xs-tools-6.2.0.iso
mkdir xentmp
mount -o loop xs-tools-6.2.0.iso xentmp
pushd xentmp/Linux
./install.sh -n
popd
umount -l xentmp
rm -rf xentmp
