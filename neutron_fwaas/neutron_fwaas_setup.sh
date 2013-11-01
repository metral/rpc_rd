#!/bin/bash

# Runtime Duration: ~ 12 minutes

# Test that the user is *not* root - devstack requires it be a user
if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as a user, not root" 1>&2
   exit 1
fi

# Install git
sudo apt-get update
sudo apt-get install git-core -y

# Install Neutron + FWaaS via Devstack
cd ~/
git clone https://github.com/openstack-dev/devstack.git

cd devstack

(cat | tee localrc) << EOF
DATABASE_PASSWORD=password
ADMIN_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=password
RABBIT_PASSWORD=password

# Enable Logging
LOGFILE=/opt/stack/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=True
SCREEN_LOGDIR=/opt/stack/logs

# Pre-requisite
ENABLED_SERVICES=rabbit,mysql,key

# Nova - Compute Service
ENABLED_SERVICES+=,n-api,n-crt,n-obj,n-cpu,n-cond,n-sch

# Glance - Image Service
ENABLED_SERVICES+=,g-api,g-reg
IMAGE_URLS+=",http://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-uec.tar.gz"

# Neutron - Networking Service
# If Neutron is not declared the old good nova-network will be used
ENABLED_SERVICES+=,q-svc,q-agt,q-dhcp,q-l3,q-meta,neutron

## Neutron - Firewaall
ENABLED_SERVICES+=,q-fwaas
EOF

./stack.sh
sleep 3

source openrc demo demo

# FWaaS Setup
echo ""
echo "Setting up FWaaS to disable ICMP"
echo "================================="
PING_RULE_ID=`neutron firewall-rule-create --protocol icmp --action deny | grep id | grep -v tenant | grep -v firewall | awk '{print $4}'`
echo "Firewall ICMP Deny Rule: $PING_RULE_ID"

SSH_RULE_ID=`neutron firewall-rule-create --protocol tcp --destination-port 22 --action allow | grep id | grep -v tenant | grep -v firewall | awk '{print $4}'`
echo "Firewall SSH Accept Rule: $SSH_RULE_ID"

POLICY_ID=`neutron firewall-policy-create --firewall-rules "$PING_RULE_ID $SSH_RULE_ID" foobar-policy | grep id | grep -v tenant | awk '{print $4}'`
echo "Firewall Policy: $POLICY_ID"

FW_ID=`neutron firewall-create $POLICY_ID | grep id | grep -v firewall | grep -v tenant | awk '{print $4}'`
echo "Firewall: $FW_ID"
sleep 3
neutron firewall-show $FW_ID


# Security group for SSH, ICMP & HTTP
neutron security-group-create foobar-group
neutron security-group-rule-create --protocol icmp --direction ingress foobar-group
neutron security-group-rule-create --direction ingress --protocol tcp  --port-range-min 22 --port-range-max 22 foobar-group

# Boot VM #1 with private network
PRIVATE_NET=`neutron net-list | grep private | awk '{print $2}'`
nova boot --image cirros-0.3.0-x86_64-uec --nic net-id=$PRIVATE_NET --security_groups foobar-group --flavor 1 foobar1
sleep 10
PRIVATE_IP=`nova show foobar1 | grep private | awk '{print $5}'`
PRIVATE_IP_ID=`neutron port-list | grep $PRIVATE_IP | awk '{print $2}'`
PRIVATE_IP1=$PRIVATE_IP
echo $PRIVATE_IP_ID
echo $PRIVATE_IP

# Create floating ip
FLOATING_IP_CREATE=`neutron floatingip-create public`
FLOATING_IP=`echo "$FLOATING_IP_CREATE" | grep floating_ip_address | awk '{print $4}'`
FLOATING_IP_ID=`echo "$FLOATING_IP_CREATE" | grep id | grep -v floating | grep -v router | grep -v tenant | grep -v port | awk '{print $4}'`
FLOATING_IP1=$FLOATING_IP
echo $FLOATING_IP

# Associate floating ip to VM
neutron floatingip-associate $FLOATING_IP_ID $PRIVATE_IP_ID

echo ""
echo "Waiting for VM to come up..."
sleep 90

echo ""
echo "Try to SSH. It should work since we allowed it in the firewall:"
echo "==============================================================="
echo "$ ssh cirros@$FLOATING_IP"
echo "Password: cubswin:)"

echo ""
echo "Try to Ping. It should *not* work since we deny it in the firewall:"
echo "==================================================================="
echo "$ ping $FLOATING_IP"

echo ""
echo "Now delete the entire firewall & try to ping & ssh again. Both should work since the firewall no longer exists:"
echo "==============================================================================================================="
echo "$ source ~/devstack/openrc demo demo"
echo "$ neutron firewall-delete $FW_ID"
echo "$ ping $FLOATING_IP"
echo "$ ssh cirros@$FLOATING_IP"
echo "Password: cubswin:)"
