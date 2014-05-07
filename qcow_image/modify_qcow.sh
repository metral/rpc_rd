#!/bin/bash

EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <QCOW_INPUT_PATH>"
    echo "You didn't provide a qcow. Downloading Ubuntu for you instead..."

    # Pull Ubuntu 12.04 UEC qcow
    INPUT_PATH=`readlink -f ./precise-server-cloudimg-amd64-disk1.img`
    wget http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img

    # Pull Ubuntu 14.04 UEC qcow
    #INPUT_PATH=`readlink -f ./trusty-server-cloudimg-amd64-disk1.img`
    #wget http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img

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
pushd modify_qcow_scripts
sudo cp xentools.sh novaagent.sh stop_cloudinit.sh /mnt/image/tmp/
popd
sudo chroot /mnt/image /bin/bash -c "su - -c 'apt-get update && apt-get install --reinstall openssh-server openssh-client -y'"
sudo chroot /mnt/image /bin/bash -c "su - -c 'cd /tmp ; ./xentools.sh ; ./novaagent.sh ; ./stop_cloudinit.sh'"
sudo chroot /mnt/image /bin/bash -c "sed -i 's#PasswordAuthentication no#PasswordAuthentication yes#g' /etc/ssh/sshd_config"

console_text="
# hvc0 - getty
#
# This service maintains a getty on hvc0 from the point the system is
# started until it is shut down again.

start on stopped rc or RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty -L 115200 hvc0 vt102"

sudo chroot /mnt/image /bin/bash -c "\
(cat | tee /etc/init/hvc0.conf) << EOF
$console_text
EOF
"

# Unmount modified qcow & cleanup
sudo mv /mnt/image/etc/resolv.conf.bak /mnt/image/etc/resolv.conf
sudo rm -rf /mtn/image/tmp/*
sudo umount -l /mnt/image/dev/
sudo umount -l /mnt/image/proc/
sudo umount -l /mnt/image
sudo qemu-nbd -d /dev/nbd0
sudo rm -rf /mnt/image
