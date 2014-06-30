#!/bin/bash

# Install & upgrade deps
apt-get update
apt-get install python-setuptools -y
easy_install pip ; easy_install --upgrade pip
pip install --upgrade virtualenv

# Source creds
source ~/openrc
export DEFAULT_MASTER_FLAVOR=`nova flavor-show m1.medium | grep id | awk '{print $4}'`
export DEFAULT_WORKER_FLAVOR=`nova flavor-show m1.medium | grep id | awk '{print $4}'`

# Install & configure Savanna
sudo apt-get install python-setuptools python-virtualenv python-dev -y

pushd ~/
virtualenv savanna-venv
savanna-venv/bin/pip install savanna
mkdir savanna-venv/etc
cp savanna-venv/share/savanna/savanna.conf.sample savanna-venv/etc/savanna.conf

sed -i "2i\os_auth_host=`echo $OS_AUTH_URL | cut -d "/" -f3 | cut -d ":" -f1`\nos_auth_port=`echo $OS_AUTH_URL | cut -d "/" -f3 | cut -d ":" -f2`\nos_admin_username=$OS_USERNAME\nos_admin_password=$OS_PASSWORD\nos_admin_tenant_name=$OS_TENANT_NAME\ndebug=true\nuse_floating_ips=false" savanna-venv/etc/savanna.conf

# To send REST requests to Savanna API, use httpie (optional)
savanna-venv/bin/pip install httpie

# Start Savanna API Server
savanna-venv/bin/python savanna-venv/bin/savanna-api --config-file savanna-venv/etc/savanna.conf > ~/savanna_api_server.log 2>&1 &
sleep 5

# Create Glance image used for Hadoop Cluster
TOKEN=`keystone token-get | grep id | grep -v user_id | awk '{print $4}'`
export AUTH_TOKEN=`echo $TOKEN | cut -d ' ' -f1`
export TENANT_ID=`echo $TOKEN | cut -d ' ' -f2`

wget http://abed605ffd85ad8177a1-c04b8ff82efc0caa202f092894159bbe.r10.cf1.rackcdn.com/savanna-0.3-vanilla-1.2.1-ubuntu-13.04.qcow2
glance image-create --name=savanna-0.3-vanilla-1.2.1-ubuntu-13.04 --disk-format=qcow2 --container-format=bare < ./savanna-0.3-vanilla-1.2.1-ubuntu-13.04.qcow2
export IMAGE_ID=`glance image-list | grep savanna | awk '{print $2}'`
export IMAGE_USER="ubuntu"

# Register Glance image with Savanna
export OS_AUTH_URL_HOST=`echo $OS_AUTH_URL | cut -d "/" -f3 | cut -d ":" -f1`
export SAVANNA_URL="http://$OS_AUTH_URL_HOST:8386/v1.0/$TENANT_ID"
savanna-venv/bin/http POST $SAVANNA_URL/images/$IMAGE_ID X-Auth-Token:$AUTH_TOKEN username=$IMAGE_USER
savanna-venv/bin/http $SAVANNA_URL/images/$IMAGE_ID/tag X-Auth-Token:$AUTH_TOKEN tags:='["vanilla", "1.2.1", "ubuntu"]'

# Create Hadoop nodegroup templates & send to Savanna
mkdir ~/nodegroup_templates
pushd ~/nodegroup_templates

(cat | tee ng_master_template_create.json) << EOF
{
    "name": "test-master-tmpl",
    "flavor_id": "$DEFAULT_MASTER_FLAVOR",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_processes": ["jobtracker", "namenode"]
}
EOF

(cat | tee ng_worker_template_create.json) << EOF
{
    "name": "test-worker-tmpl",
    "flavor_id": "$DEFAULT_WORKER_FLAVOR",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_processes": ["tasktracker", "datanode"]
}
EOF
popd

OUTPUT=`savanna-venv/bin/http $SAVANNA_URL/node-group-templates X-Auth-Token:$AUTH_TOKEN < ~/nodegroup_templates/ng_master_template_create.json`
MASTER="$OUTPUT"
echo $MASTER
MASTER_TEMPLATE_ID=`echo $MASTER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node_group_template"]["id"]'`
echo $MASTER_TEMPLATE_ID

OUTPUT=`savanna-venv/bin/http $SAVANNA_URL/node-group-templates X-Auth-Token:$AUTH_TOKEN < ~/nodegroup_templates/ng_worker_template_create.json`
WORKER="$OUTPUT"
echo $WORKER
WORKER_TEMPLATE_ID=`echo $WORKER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node_group_template"]["id"]'`
echo $WORKER_TEMPLATE_ID

# Create Hadoop cluster template & send to Savanna
pushd ~/nodegroup_templates
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
popd

savanna-venv/bin/http $SAVANNA_URL/cluster-templates X-Auth-Token:$AUTH_TOKEN < ~/nodegroup_templates/cluster_template_create.json

# Setup security groups
nova secgroup-add-rule default tcp 50010 50010 0.0.0.0/0
nova secgroup-add-rule default tcp 50030 50030 0.0.0.0/0
nova secgroup-add-rule default tcp 50060 50060 0.0.0.0/0
nova secgroup-add-rule default tcp 50070 50070 0.0.0.0/0
