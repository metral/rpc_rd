#!/bin/bash

# Runtime Duration: ~ 5 minutes

# Test that the user is *not* root - devstack requires it be a user
if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as a user, not root" 1>&2
   exit 1
fi

# Install git
sudo apt-get update
sudo apt-get install git -y

# Install trove-integration & devstack (via trove)
cd ~/
git clone https://github.com/moniker-dns/devstack.git
cd devstack

(cat | tee localrc) << EOF
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=tokentoken

# Just the basics to start with!
ENABLED_SERVICES=rabbit,mysql,key

# Enable core Designate services
ENABLED_SERVICES+=,designate,designate-api,designate-central

# Optional Designate services
#ENABLED_SERVICES+=,designate-sink
#ENABLED_SERVICES+=,designate-agent

# ** Everything below is optional ***

# Enable Horizon with Designate integration (needs nova)
#ENABLED_SERVICES+=,horizon
#HORIZON_REPO=git://github.com/moniker-dns/horizon.git
#HORIZON_BRANCH=designate

# Enable Nova (needs glance)
#ENABLED_SERVICES+=,n-api,n-crt,n-obj,n-cpu,n-net,n-cond,n-sch
#IMAGE_URLS+=",https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img"

# Enable Glance
#ENABLED_SERVICES+=,g-api,g-reg
EOF

./stack.sh
source openrc admin admin

# Usage examples
echo ""
DOMAIN_ID=`designate domain-create --name foobar.net. --email foo@bar.com | grep id | awk '{print $4}'`
echo "Created Domain: $DOMAIN_ID"
RECORD_ID=`designate record-create "$DOMAIN_ID" --type A --name www.foobar.net. --data 127.0.0.1 | grep id | grep -v domain_id | awk '{print $4}'`
echo "Created Record: $RECORD_ID"
designate domain-list
designate record-list $DOMAIN_ID
designate record-get $DOMAIN_ID $RECORD_ID
