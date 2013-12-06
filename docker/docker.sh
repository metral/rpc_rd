#!/bin/bash

# Runtime Duration: ~ 12 minutes

# Test that the user is *not* root - devstack requires it be a user
if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as a user, not root" 1>&2
   exit 1
fi

# Install docker
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker -y

# Install git
sudo apt-get install git-core socat -y

# Install Devstack
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
#enable_service n-net 

# Docker Driver
VIRT_DRIVER=docker
EOF

# do Patch
sed -i 's/echo "Waiting for docker.*/echo "Waiting for docker deamon to start..." \nwhile [ ! -f $DOCKER_PID_FILE ]\ndo\n  sleep 1\ndone/g' ~/devstack/tools/docker/install_docker.sh

# install
sudo ./tools/docker/install_docker.sh
sudo chgrp $(groups |cut -d' ' -f1) /var/run/docker.sock

# replace non-working registry image on Rackspace cloud with one that works
docker rmi docker-registry
cd files
rm -rf docker-registry.tar.gz
#wget http://6bc6e9aa96b3ac52a4f4-abffaf981a2eb6b5e528f6c31e120f53.r19.cf2.rackcdn.com/docker-registry.tar.gz
wget http://9cfc5703ff03f7848eb6-c6bad15b620431ee689956f931bdd820.r96.cf1.rackcdn.com/docker-registry.tar.gz
docker import - docker-registry <docker-registry.tar.gz
cd ../

./stack.sh
sleep 3

TENANT_NAME=admin
USERNAME=admin
PASSWORD=password
source ~/devstack/openrc admin admin
TENANT_ID=`keystone tenant-list | grep $USERNAME | grep -v invisible* | awk '{print $2}'`
 
REQUEST="{\"auth\": {\"tenantName\":\"$TENANT_NAME\", \"passwordCredentials\": {\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}}}"
RAW_TOKEN=`curl -s -d "$REQUEST" -H "Content-type: application/json" "http://localhost:5000/v2.0/tokens"`
TOKEN=`echo $RAW_TOKEN | python -c "import sys; import json; tok = json.loads(sys.stdin.read()); print tok['access']['token']['id'];"`

source ~/devstack/openrc admin admin
PRIVATE_NET=`neutron net-list | grep private | awk '{print $2}'`
IMAGE=`glance image-list | grep docker | awk '{print $2}'`

curl -i http://localhost:8774/v2/$TENANT_ID/servers \
-X POST -H "X-Auth-Project-Id: admin" \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "X-Auth-Token: $TOKEN" \
-d '{"server": {"name": "foobar", "imageRef": "'"$IMAGE"'", "flavorRef": "1", "max_count": 1, "min_count": 1, "networks": [{"uuid": "'"$PRIVATE_NET"'"}]}}'

sleep 5
docker ps
