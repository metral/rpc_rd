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

# Install Neutron + LBaaS via Devstack
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

## Neutron - Load Balancing
ENABLED_SERVICES+=,q-lbaas
EOF

./stack.sh
sleep 3

source openrc admin admin

# Setup networking via Neutron

# Security group for SSH, ICMP & HTTP
neutron security-group-create foobar-group
neutron security-group-rule-create --protocol icmp --direction ingress foobar-group
neutron security-group-rule-create --direction ingress --protocol tcp  --port-range-min 80 --port-range-max 80 foobar-group
neutron security-group-rule-create --direction ingress --protocol tcp  --port-range-min 22 --port-range-max 22 foobar-group

# Boot VM #1 with private network
PRIVATE_NET=`neutron net-list | grep private | awk '{print $2}'`
nova boot --image cirros-0.3.0-x86_64-uec --nic net-id=$PRIVATE_NET --security_groups foobar-group --flavor 1 foobar1
sleep 5
PRIVATE_IP=`nova show foobar1 | grep private | awk '{print $5}'`
PRIVATE_IP_ID=`neutron port-list | grep $PRIVATE_IP | awk '{print $2}'`
PRIVATE_IP1=$PRIVATE_IP
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
echo "Try to SSH in a bit after VM comes up (~ 1-2 min):"
echo "================================================="
echo "$ ssh cirros@$FLOATING_IP"
echo "Password: cubswin:)"




# Boot VM #2 with private network
PRIVATE_NET=`neutron net-list | grep private | awk '{print $2}'`
nova boot --image cirros-0.3.0-x86_64-uec --nic net-id=$PRIVATE_NET --security_groups foobar-group --flavor 1 foobar2
sleep 5
PRIVATE_IP=`nova show foobar2 | grep private | awk '{print $5}'`
PRIVATE_IP_ID=`neutron port-list | grep $PRIVATE_IP | awk '{print $2}'`
PRIVATE_IP2=$PRIVATE_IP
echo $PRIVATE_IP

# Create floating ip
FLOATING_IP_CREATE=`neutron floatingip-create public`
FLOATING_IP=`echo "$FLOATING_IP_CREATE" | grep floating_ip_address | awk '{print $4}'`
FLOATING_IP_ID=`echo "$FLOATING_IP_CREATE" | grep id | grep -v floating | grep -v router | grep -v tenant | grep -v port | awk '{print $4}'`
FLOATING_IP2=$FLOATING_IP
echo $FLOATING_IP2

# Associate floating ip to VM
neutron floatingip-associate $FLOATING_IP_ID $PRIVATE_IP_ID

echo ""
echo "Try to SSH in a bit after VM comes up (~ 1-2 min):"
echo "================================================="
echo "$ ssh cirros@$FLOATING_IP"
echo "Password: cubswin:)"


echo ""
echo "Waiting for VM's to come up..."
sleep 120


# Load Balancing Topology Setup
PRIVATE_SUBNET_ID=`neutron subnet-list | grep private | awk '{print $2}'`
neutron lb-pool-create --lb-method ROUND_ROBIN --name mypool-foobar --protocol HTTP --subnet-id $PRIVATE_SUBNET_ID
neutron lb-member-create --address $PRIVATE_IP1 --protocol-port 80 mypool-foobar
neutron lb-member-create --address $PRIVATE_IP2 --protocol-port 80 mypool-foobar
HEALTH_MONITOR_ID=`neutron lb-healthmonitor-create --delay 3 --type HTTP --max-retries 3 --timeout 3 | grep id | grep -v tenant | awk '{print $4}'`
neutron lb-healthmonitor-associate $HEALTH_MONITOR_ID mypool-foobar
VIP=`neutron lb-vip-create --name myvip-foobar --protocol-port 80 --protocol HTTP --subnet-id $PRIVATE_SUBNET_ID mypool-foobar | grep address | awk '{print $4}'`
VIP_ID=`neutron port-list | grep 10.0.0.5 | awk '{print $2}'`

FLOATING_IP_CREATE=`neutron floatingip-create public`
FLOATING_IP=`echo "$FLOATING_IP_CREATE" | grep floating_ip_address | awk '{print $4}'`
FLOATING_IP_ID=`echo "$FLOATING_IP_CREATE" | grep id | grep -v floating | grep -v router | grep -v tenant | grep -v port | awk '{print $4}'`
FLOATING_IP3=$FLOATING_IP
neutron floatingip-associate $FLOATING_IP_ID $VIP_ID

echo ""
echo "Load Balancer VIP: $VIP"
echo "Load Balancer Floating IP: $FLOATING_IP3"
echo ""
echo "Run the following on both VM's:"
echo "==============================="
echo "$ while true; do echo -e 'HTTP/1.0 200 OK\r\n\r\n<servername>' | sudo nc -l -p 80 ; done"
echo ""
echo "Then test each server & VIP using their Floating IP's:"
echo "======================================================"
echo "VM1: $ wget -O - http://$FLOATING_IP1"
echo "VM2: $ wget -O - http://$FLOATING_IP2"
echo "VIP: $ wget -O - http://$FLOATING_IP3"
