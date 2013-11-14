#!/bin/bash

# Runtime Duration: ~ 12-15 minutes

# Test that the user is *not* root - devstack requires it be a user
if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as a user, not root" 1>&2
   exit 1
fi

# Install git
sudo apt-get update
sudo apt-get install git-core -y

# Install Neutron + VPNaaS via Devstack
cd ~/
git clone https://github.com/openstack-dev/devstack.git

cd devstack

(cat | tee localrc) << EOF
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

# Neutron - VPN
DEST=/opt/stack
disable_service n-net
enable_service tempest
enable_service q-vpn
API_RATE_LIMIT=False
VOLUME_BACKING_FILE_SIZE=4G
VIRT_DRIVER=libvirt
SWIFT_REPLICAS=1
export OS_NO_CACHE=True
SYSLOG=True
SKIP_EXERCISES=boot_from_volume,client-env
ROOTSLEEP=0
ACTIVE_TIMEOUT=60
Q_USE_SECGROUP=True
BOOT_TIMEOUT=90
ASSOCIATE_TIMEOUT=60
ADMIN_PASSWORD=openstack
MYSQL_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=openstack
SERVICE_TOKEN=tokentoken
Q_PLUGIN=openvswitch
Q_USE_DEBUG_COMMAND=True
IPSEC_PACKAGE=openswan

PUBLIC_SUBNET_NAME=east-subnet
PRIVATE_SUBNET_NAME=myeast-subnet
FIXED_RANGE=10.1.0.0/24
NETWORK_GATEWAY=10.1.0.1
PUBLIC_NETWORK_GATEWAY=172.24.4.225
Q_FLOATING_ALLOCATION_POOL=start=172.24.4.226,end=172.24.4.231
EOF

./stack.sh
sleep 5

source openrc demo demo

# Security group for SSH, ICMP
neutron security-group-create foobar-group
neutron security-group-rule-create --protocol icmp --direction ingress foobar-group
neutron security-group-rule-create --direction ingress --protocol udp  --port-range-min 500 --port-range-max 500 foobar-group
neutron security-group-rule-create --direction ingress --protocol udp  --port-range-min 4500 --port-range-max 4500 foobar-group
neutron security-group-rule-create --direction ingress --protocol tcp  --port-range-min 22 --port-range-max 22 foobar-group

# Boot VM with private network
PRIVATE_NET=`neutron net-list | grep private | awk '{print $2}'`
nova boot --image cirros-0.3.0-x86_64-uec --nic net-id=$PRIVATE_NET --security_groups foobar-group --flavor 1 foobar1
sleep 20
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

# NAT Setup & Host Port Forwarding to VM
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Disable accept_redirects & send_redirects
for f in /proc/sys/net/ipv4/conf/*/accept_redirects; do echo 0 | sudo tee $f > /dev/null; done
for f in /proc/sys/net/ipv4/conf/*/send_redirects; do echo 0 | sudo tee $f > /dev/null; done  
sudo ipsec verify 

# Setup & configure network interfaces, routes & firewall rules
sudo ovs-vsctl add-port br-ex eth2      # Add the isolated / cloud network interface as a port on br-ex
sudo ip route add 172.24.4.232/32 via 172.24.4.225      # Add static route on the host to west br-ex interface via the host br-ex interface
sudo ip route add 172.24.4.233/32 via 172.24.4.232      # Add static route on the host to west neutron router gateway qr-<ID> interface via the west br-ex interface (which is via the host br-ex interface)

neutronrouter=`sudo ip netns | grep qrouter`    # Grab east neutron router name
sudo ip netns exec $neutronrouter ip route add 172.24.4.232/32 via 172.24.4.225     # Add static route on the neutron router to west br-ex interface via the host br-ex interface
sudo ip netns exec $neutronrouter ip route add 172.24.4.233/32 via 172.24.4.225     # Add static route on the neutron router to west neutron router gateway qr-<ID> interface via the host br-ex interface

neutronrouter_gateway=`sudo ip netns exec $neutronrouter ifconfig | grep qg | awk '{print $1}'`    # Grab east neutron router gateway name
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT       # Forward connection tracking
sudo iptables -A FORWARD -i br-ex -o $neutronrouter_gateway -m state --state RELATED,ESTABLISHED -j ACCEPT       # Forward west neutron gateway packets to br-ex
sudo iptables -A FORWARD -i $neutronrouter_gateway -o br-ex -j ACCEPT       # Forward br-ex packets to the west neutron router gateway

# Create VPNaaS ikepolicy, ipsecpolicy & ipsec-site-connection
neutron vpn-ikepolicy-create ikepolicy1
neutron vpn-ipsecpolicy-create ipsecpolicy1
neutron vpn-service-create --name myvpn --description "My vpn service" router1 myeast-subnet
neutron ipsec-site-connection-create --name conn_east --vpnservice-id myvpn --ikepolicy-id ikepolicy1 --ipsecpolicy-id ipsecpolicy1 --peer-address 172.24.4.233 --peer-id 172.24.4.233 --peer-cidr 10.2.0.0/24 --psk secret  

echo ""
echo "SSH into VM & ping the west private subnet:"
echo "==========================================="
echo "$ ssh cirros@$FLOATING_IP"
echo "Password: cubswin:)"
echo "vm: $ ping 10.2.0.4"

sleep 5
neutron ipsec-site-connection-list
