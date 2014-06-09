#!/bin/bash

sudo apt-get update

# install java 1.7
sudo apt-get install openjdk-7-jdk -y
sudo update-java-alternatives -s java-1.7.0-openjdk-amd64

# install logstash
pushd /opt
curl -O https://download.elasticsearch.org/logstash/logstash/logstash-1.4.1.tar.gz
tar zxvf logstash*.tar.gz
rm -rf logstash*.tar.gz
popd
cp agent.conf /opt/logstash*
cp extras /opt/logstash*/patterns/

# install elasticsearch
pushd /opt
curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz
tar zxvf elasticsearch*.tar.gz
rm -rf elasticsearch*.tar.gz
popd

# install kibana
pushd /opt
wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
tar zxvf kibana*.tar.gz
rm -rf kibana*.tar.gz
popd
