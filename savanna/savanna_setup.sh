#!/bin/bash

# Runtime Duration: ~ 15 minutes

# Test that the user is *not* root - devstack requires it be a user
if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as a user, not root" 1>&2
   exit 1
fi

# Install git
sudo apt-get update
sudo apt-get install git-core -y

# Install trove-integration & devstack (via trove)
cd ~/
git clone https://github.com/openstack-dev/devstack.git

USERHOME=$(eval echo ~${SUDO_USER})
DEST=${USERHOME}/test_dest
mkdir -p ${DEST}/data
mkdir -p ${DEST}/logs/screen

cd devstack
(cat | sudo tee localrc) << EOF
ADMIN_PASSWORD=nova
MYSQL_PASSWORD=nova
RABBIT_PASSWORD=nova
SERVICE_PASSWORD=nova
SERVICE_TOKEN=nova

# Enable Swift
ENABLED_SERVICES+=,swift

SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data

# Force checkout prerequsites
# FORCE_PREREQ=1

# keystone is now configured by default to use PKI as the token format which produces huge tokens.
# set UUID as keystone token format which is much shorter and easier to work with.
KEYSTONE_TOKEN_FORMAT=UUID

# Change the FLOATING_RANGE to whatever IPs VM is working in.
# In NAT mode it is subnet VMWare Fusion provides, in bridged mode it is your local network.
#FLOATING_RANGE=192.168.55.224/27

# Enable auto assignment of floating IPs. By default Savanna expects this setting to be enabled
#EXTRA_OPTS=(auto_assign_floating_ip=True)

# Enable logging
SCREEN_LOGDIR=$DEST/logs/screen
EOF

./stack.sh

sudo apt-get install python-setuptools python-virtualenv python-dev

virtualenv savanna-venv
savanna-venv/bin/pip install savanna
mkdir savanna-venv/etc
cp savanna-venv/share/savanna/savanna.conf.sample savanna-venv/etc/savanna.conf
