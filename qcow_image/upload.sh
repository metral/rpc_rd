#!/bin/bash

RAX_USERNAME=$1
RAX_APIKEY=$2
RAX_TENANT_ID=$3
IMAGE_PATH=$4
IMAGE_NAME=$5

IMAGESURL="https://ord.images.api.rackspacecloud.com/v2"

RAX_TOKEN=`curl -s -XPOST https://identity.api.rackspacecloud.com/v2.0/tokens \
    -d'{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$RAX_USERNAME'","apiKey":"'$RAX_APIKEY'"}}}' \
    -H"Content-type:application/json" | \
    python -c 'import sys,json;data=json.loads(sys.stdin.read());print data["access"]["token"]["id"]'`
 
# Create the import image task
curl $IMAGESURL/tasks -X POST -H "X-Auth-Project-Id: $RAX_TENANT_ID" -H "Accept: application/json"  -H "Content-Type: application/json" -H "X-Tenant-Id: $RAX_TENANT_ID" -H "X-User-Id: $RAX_TENANT_ID" -H "X-Auth-Token: $RAX_TOKEN" -d '{"type": "import", "input": {"import_from": '$IMAGE_PATH', "image_properties" : {"name": '$IMAGE_NAME'}}}' 
