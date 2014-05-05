#!/bin/bash

wget http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img

sudo modprobe nbd max_part=14
sudo qemu-nbd -c /dev/nbd0 precise-server-cloudimg-amd64-disk1.img
sudo partprobe /dev/nbd0
sudo mkdir /mnt/image

sudo mount /dev/nbd0p1 /mnt/image
sudo mount --bind /dev /mnt/image/dev
sudo mount --bind /proc /mnt/image/proc
sudo mv /mnt/image/etc/resolv.conf /mnt/image/etc/resolv.conf.bak
sudo cp -f /etc/resolv.conf /mnt/image/etc/resolv.conf

sudo cp xentools.sh novaagent.sh stop_cloudinit.sh /mnt/image/tmp/
sudo chroot /mnt/image /bin/bash -c "su - -c 'usermod --password ubuntu ubuntu'"
sudo chroot /mnt/image /bin/bash -c "su - -c 'cd /tmp ; ./xentools.sh ; ./novaagent.sh ; ./stop_cloudinit.sh'"

sudo mv /mnt/image/etc/resolv.conf.bak /mnt/image/etc/resolv.conf
sudo rm -rf /mtn/image/tmp/*
sudo umount -l /mnt/image/dev/
sudo umount -l /mnt/image/proc/
sudo umount -l /mnt/image
sudo qemu-nbd -d /dev/nbd0
sudo rm -rf /mnt/image
