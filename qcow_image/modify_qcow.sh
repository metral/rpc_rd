#!/bin/bash

EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
    echo "You didn't provide a qcow. Downloading Ubuntu for you instead..."
    echo ""

    # Pull Ubuntu 14.04 UEC qcow
    INPUT_PATH=`readlink -f ./trusty-server-cloudimg-amd64-disk1.img`
    wget http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img

else
    INPUT_PATH=`readlink -f $1`
fi

# Mount qcow & give it access to sys resources & Internet
sudo modprobe nbd max_part=14
sudo qemu-nbd -c /dev/nbd0 $INPUT_PATH
sudo mkdir /mnt/image

sudo mount /dev/nbd0p1 /mnt/image
sudo mount --bind /dev /mnt/image/dev
sudo mount --bind /proc /mnt/image/proc
sudo mv /mnt/image/etc/resolv.conf /mnt/image/etc/resolv.conf.bak
sudo cp -f /etc/resolv.conf /mnt/image/etc/resolv.conf

# Modify qcow to work for RAX public cloud
pushd distro_scripts 
sudo cp ubuntu_14.04.sh /mnt/image/tmp/
popd
sudo chroot /mnt/image /bin/bash -c "su - -c 'cd /tmp ; ./ubuntu_14.04.sh'"

# Unmount modified qcow & cleanup
sudo mv /mnt/image/etc/resolv.conf.bak /mnt/image/etc/resolv.conf
sudo rm -rf /mtn/image/tmp/*
sudo umount -l /mnt/image/dev/
sudo umount -l /mnt/image/proc/
sudo umount -l /mnt/image
sudo qemu-nbd -d /dev/nbd0
sudo rm -rf /mnt/image
