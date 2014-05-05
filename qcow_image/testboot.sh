#!/bin/bash

bridge=br-eth0
tap=$(sudo tunctl -u $(whoami) -b)
sudo ip link set $tap up
sleep 1
sudo brctl addif $bridge $tap

qemu-system-x86_64 \
    -machine accel=kvm:tcg \
    -drive file=precise-server-cloudimg-amd64-disk1.img,if=virtio -boot c -m 300 \
    -k en-us \
    -net nic,vlan=0,macaddr=52:54:00:87:fc:38,model=virtio \
    -net tap,vlan=0,ifname=$tap,script=no,downscript=no -vnc :2 &

#sudo brctl delif $bridge $tap
#sudo ip link set $tap down
#sudo tunctl -d $tap
