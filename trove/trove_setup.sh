#!/bin/bash

# Runtime Duration: ~ 15 minutes

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
git clone https://github.com/openstack/trove-integration.git
cd ~/trove-integration/scripts
~/trove-integration/scripts/redstack install
~/trove-integration/scripts/redstack kick-start mysql
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE

# 'trove-integration' usage example commands
# $ cd ~/trove-integration/scripts/

# Create trove instance
# $ ./redstack rd-client instance create --name=foobar --flavor=7 --size=1
# $ ./redstack rd-client instance get --id=<UUID_IN_JSON_FROM_INSTANCE_CREATE>
# $ ssh <IP_RETURNED_FROM_INSTANCE_GET> - VM takes a bit to come up, be patient

# Create database in trove instance
# Once this says that the instance's status is READY: $ ./redstack rd-client instance get --id=<UUID_IN_JSON_FROM_INSTANCE_CREATE>
# $ ./redstack rd-client database create --name=foobar-db --id=<UUID_IN_JSON_FROM_INSTANCE_CREATE>
# $ ./redstack rd-client root create --id=<UUID_IN_JSON_FROM_INSTANCE_CREATE>

# Log into trove instance MySQL db
# $ mysql -uroot -p<PASSWORD_RETURNED_FROM_ROOT_CREATE> -h <IP_RETURNED_FROM_INSTANCE_GET>

# Check logs (in trove instance)
#cat /tmp/logfile.txt
