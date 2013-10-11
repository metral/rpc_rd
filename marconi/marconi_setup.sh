#!/bin/bash

# Runtime Duration: ~ 2 minutes

# Install deps
sudo apt-get update
sudo apt-get install git python-setuptools -y

# Install MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' |
sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update
sudo apt-get install mongodb-10gen

# Clone Marconi
git clone https://github.com/openstack/marconi.git
mkdir ~/.marconi
cp ~/marconi/etc/*.conf-sample ~/.marconi/

mv ~/.marconi/logging.conf-sample ~/.marconi/logging.conf
mv ~/.marconi/marconi-proxy.conf-sample ~/.marconi/marconi-proxy.conf
mv ~/.marconi/marconi-queues.conf-sample ~/.marconi/marconi-queues.conf

sed -i "s/uri = mongodb:.*/uri = mongodb:\/\/localhost/g" ~/.marconi/marconi-queues.conf

sudo easy_install virtualenv
sudo easy_install pip

sudo pip install -e marconi

cd ~/marconi
python setup.py develop

sudo mkdir -p /var/log/marconi
sudo touch /var/log/marconi/queues.log

# Run dev server
# $ marconi-server -v


# API Interaction Examples
# ------------------------

# Get Home Doc
# $ curl localhost:8888/v1

# Create Queue
# $ curl -X PUT localhost:8888/v1/queues/foobar

# List Queues
# $ curl localhost:8888/v1/queues/

# Get Queue Stats
# $ curl localhost:8888/v1/queues/foobar/stats

# Create Message
# $ curl -X POST \
#    -H "Client-ID: 97b64000-2526-11e3-b088-d85c1300734c" \
#    -H "Content-Type: application/json" \
#    -d '[{"ttl": 300, "body": {"event": "FakeEvent"}}]' \
#    localhost:8888/v1/queues/foobar/messages

# Get Queue Stats (after message created)
# $ curl localhost:8888/v1/queues/foobar/stats

# List Message Created
# $ curl localhost:8888/v1/queues/foobar/messages/<MESSAGE_ID_AFTER_CREATED>

# Delete Message Created
# $ curl -X DELETE localhost:8888/v1/queues/foobar/messages/<MESSAGE_ID_AFTER_CREATED>

# Verify message got deleted
# $ curl localhost:8888/v1/queues/foobar/stats
