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

# Install Savanna via devstack
cd ~/
git clone https://github.com/openstack-dev/devstack.git

USERHOME=$(eval echo ~${SUDO_USER})
DEST=${USERHOME}/test_dest
mkdir -p ${DEST}/data
mkdir -p ${DEST}/logs/screen

cd devstack
(cat | tee localrc) << EOF
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

# Create virtualenv for Savanna
cd ~/
sudo apt-get install python-setuptools python-virtualenv python-dev

virtualenv savanna-venv
#savanna-venv/bin/pip install savanna
savanna-venv/bin/pip install 'http://tarballs.openstack.org/savanna/savanna-master.tar.gz'
mkdir savanna-venv/etc
cp savanna-venv/share/savanna/savanna.conf.sample savanna-venv/etc/savanna.conf

#To send REST requests to Savanna API, use httpie (optional)
sudo pip install httpie

# Provision Hadoop Cluster
(cat | tee ~/creds) << EOF
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=nova
EOF

source creds

TOKEN=`keystone token-get | grep id | grep -v user_id | awk '{print $4}'`
export AUTH_TOKEN=`echo $TOKEN | cut -d ' ' -f1`
export TENANT_ID=`echo $TOKEN | cut -d ' ' -f2`

# Create Glance image used for Hadoop Cluster
wget http://savanna-files.mirantis.com/savanna-0.2-vanilla-1.1.2-ubuntu-12.10.qcow2
glance image-create --name=savanna-0.2-vanilla-hadoop-ubuntu.qcow2 --disk-format=qcow2 --container-format=bare < ./savanna-0.2-vanilla-1.1.2-ubuntu-12.10.qcow2
glance image-list
export IMAGE_ID=`glance image-list | grep savanna | awk '{print $2}'`

# Create ssh keypair
nova keypair-add savanna > savanna.pem ; chmod 0600 savanna.pem

# Start Savanna API Server
savanna-venv/bin/python savanna-venv/bin/savanna-api --config-file savanna-venv/etc/savanna.conf > ~/savanna_api_server.log 2>&1 &
sleep 2

# Register Glance image with Savanna
export SAVANNA_URL="http://localhost:8386/v1.0/$TENANT_ID"
http POST $SAVANNA_URL/images/$IMAGE_ID X-Auth-Token:$AUTH_TOKEN username=admin
http $SAVANNA_URL/images/$IMAGE_ID/tag X-Auth-Token:$AUTH_TOKEN tags:='["vanilla", "1.2.1", "ubuntu"]'

# Create Hadoop nodegroup templates & send to Savanna
mkdir ~/nodegroup_templates
cd ~/nodegroup_templates

(cat | tee ng_master_template_create.json) << EOF
{
    "name": "test-master-tmpl",
    "flavor_id": "3",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_processes": ["jobtracker", "namenode"]
}
EOF

(cat | tee ng_worker_template_create.json) << EOF
{
    "name": "test-worker-tmpl",
    "flavor_id": "3",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_processes": ["tasktracker", "datanode"]
}
EOF

OUTPUT=`http $SAVANNA_URL/node-group-templates X-Auth-Token:$AUTH_TOKEN < ng_master_template_create.json`
MASTER="$OUTPUT"
echo $MASTER
MASTER_TEMPLATE_ID=`echo $MASTER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node_group_template"]["id"]'`
echo $MASTER_TEMPLATE_ID

OUTPUT=`http $SAVANNA_URL/node-group-templates X-Auth-Token:$AUTH_TOKEN < ng_worker_template_create.json`
WORKER="$OUTPUT"
echo $WORKER
WORKER_TEMPLATE_ID=`echo $WORKER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node_group_template"]["id"]'`
echo $WORKER_TEMPLATE_ID

# Create Hadoop cluster template & send to Savanna
(cat | tee cluster_template_create.json) << EOF
{
    "name": "demo-cluster-template",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_groups": [
        {
            "name": "master",
            "node_group_template_id": "$MASTER_TEMPLATE_ID",
            "count": 1
        },
        {
            "name": "workers",
            "node_group_template_id": "$WORKER_TEMPLATE_ID",
            "count": 2
        }
    ]
}
EOF

OUTPUT=`http $SAVANNA_URL/cluster-templates X-Auth-Token:$AUTH_TOKEN < cluster_template_create.json`
CLUSTER="$OUTPUT"
echo $CLUSTER
CLUSTER_TEMPLATE_ID=`echo $CLUSTER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["cluster_template"]["id"]'`
echo $CLUSTER_TEMPLATE_ID

# Create Hadoop cluster
(cat | tee cluster_create.json) << EOF
{
    "name": "cluster-1",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "cluster_template_id" : "$CLUSTER_TEMPLATE_ID",
    "user_keypair_id": "savanna",
    "default_image_id": "$IMAGE_ID"
}
EOF

http $SAVANNA_URL/clusters X-Auth-Token:$AUTH_TOKEN < cluster_create.json

echo ""
echo "================================================"
echo "export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/"
echo "export OS_TENANT_NAME=admin"
echo "export OS_USERNAME=admin"
echo "export OS_PASSWORD=nova"
echo "export AUTH_TOKEN=$AUTH_TOKEN"
echo "export TENANT_ID=$TENANT_ID"
echo "export IMAGE_ID=$IMAGE_ID"
echo "================================================"

sleep 10
source ~/creds
nova list

echo ""
echo "All done. VM's should be building/booting above. VM Booting + Hadoop launch will take a while."

# Usage example
echo ""
echo"Usage - Create a Hadoop job on the master node (should be 10.0.0.2)"
echo"-------------------------------------------------------------------"
echo "$ ssh -i savanna.pem ubuntu@10.0.0.2"
echo "$ sudo chmod 777 /usr/share/hadoop"
echo "$ sudo su hadoop"
echo "$ cd /usr/share/hadoop"
echo "$ hadoop jar hadoop-examples-1.1.2.jar pi 10 100"
