#!/bin/bash

# Create Hadoop cluster
source ~/openrc
pushd ~/ > /dev/null 2>&1

# Add keypair
if [ ! -f ~/.ssh/id_rsa ];then
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
fi
nova keypair-add adminKey --pub-key ~/.ssh/id_rsa.pub > /dev/null 2>&1

TOKEN=`keystone token-get | grep id | grep -v user_id | awk '{print $4}'`
export AUTH_TOKEN=`echo $TOKEN | cut -d ' ' -f1`
export TENANT_ID=`echo $TOKEN | cut -d ' ' -f2`
export OS_AUTH_URL_HOST=`echo $OS_AUTH_URL | cut -d "/" -f3 | cut -d ":" -f1`
export SAVANNA_URL="http://$OS_AUTH_URL_HOST:8386/v1.0/$TENANT_ID"
export IMAGE_ID=`glance image-list | grep savanna | awk '{print $2}'`
export IMAGE_USER="ubuntu"

CLUSTER_TEMPLATES=`savanna-venv/bin/http $SAVANNA_URL/cluster-templates X-Auth-Token:$AUTH_TOKEN`
CLUSTER_TEMPLATE_ID=`echo $CLUSTER_TEMPLATES | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["cluster_templates"][0]["id"]'`

# Create Hadoop cluster
NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
CLUSTER_FILE="/tmp/cluster_create_$NEW_UUID.json"
(cat | tee $CLUSTER_FILE) > /dev/null 2>&1 << EOF
{
    "name": "cluster-$NEW_UUID",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "cluster_template_id" : "$CLUSTER_TEMPLATE_ID",
    "user_keypair_id": "adminKey",
    "default_image_id": "$IMAGE_ID"
}
EOF

CREATE_CLUSTER_OUTPUT=`savanna-venv/bin/http $SAVANNA_URL/clusters X-Auth-Token:$AUTH_TOKEN < $CLUSTER_FILE`
CLUSTER_ID=`echo $CREATE_CLUSTER_OUTPUT | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["cluster"]["id"]'`

function get_cluster_status(){
    CLUSTER_DATA=`savanna-venv/bin/http $SAVANNA_URL/clusters/$CLUSTER_ID X-Auth-Token:$AUTH_TOKEN`
    STATUS=`echo $CLUSTER_DATA | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["cluster"]["status"]'`
    echo "$STATUS"
}

CLUSTER_STATUS=$(get_cluster_status)
echo "Cluster 'cluster-$NEW_UUID' is now '$CLUSTER_STATUS'"

while [ "$CLUSTER_STATUS" != "Active" ]; do
    echo "Cluster 'cluster-$NEW_UUID' is now '$CLUSTER_STATUS'"
    sleep 2
    CLUSTER_STATUS=$(get_cluster_status)
done
echo "Cluster 'cluster-$NEW_UUID' is now '$CLUSTER_STATUS'"

MASTER_IP=`nova show cluster-$NEW_UUID-master-001 | grep "public\ network" | awk '{print $5}'`
WORKER1_IP=`nova show cluster-$NEW_UUID-workers-001 | grep "public\ network" | awk '{print $5}'`
WORKER2_IP=`nova show cluster-$NEW_UUID-workers-002 | grep "public\ network" | awk '{print $5}'`
ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo chmod 777 /usr/share/hadoop ; sudo sed -i 's/128m/2048m/g' /etc/hadoop/hadoop-env.sh ; sudo su hadoop -c 'stop-all.sh ; start-all.sh'" > /dev/null 2>&1
ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$WORKER1_IP "sudo chmod 777 /usr/share/hadoop ; sudo sed -i 's/128m/2048m/g' /etc/hadoop/hadoop-env.sh ; sudo su hadoop -c 'hadoop-daemon.sh stop datanode ; hadoop-daemon.sh start datanode ; hadoop-daemon.sh stop jobtracker ; hadoop-daemon.sh start jobtracker ;'" > /dev/null 2>&1
ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$WORKER2_IP "sudo chmod 777 /usr/share/hadoop ; sudo sed -i 's/128m/2048m/g' /etc/hadoop/hadoop-env.sh ; sudo su hadoop -c 'hadoop-daemon.sh stop datanode ; hadoop-daemon.sh start datanode ; hadoop-daemon.sh stop jobtracker ; hadoop-daemon.sh start jobtracker ;'" > /dev/null 2>&1

function get_hadoop_avail_nodes(){
    STATE=`ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo su hadoop -c 'hadoop dfsadmin -report | grep Datanodes | cut -d \" \" -f3'"`
    echo "$STATE"
}

AVAILABLE_NODES=$(get_hadoop_avail_nodes)
while [ "$AVAILABLE_NODES" != "2" ]; do
    echo "Hadoop cluster is *not* ready - Available node count: $AVAILABLE_NODES"
    sleep 2
    AVAILABLE_NODES=$(get_hadoop_avail_nodes)
done
echo "Hadoop cluster is ready - Available node count: $AVAILABLE_NODES"
