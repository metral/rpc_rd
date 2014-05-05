#!/bin/bash

wget http://boot.rackspace.com/files/xentools/xs-tools-6.2.0.iso
mkdir tmp
mount -o loop xs-tools-6.2.0.iso tmp
cd tmp/Linux
./install.sh -n
cd ../..
umount tmp
rm -rf tmp
