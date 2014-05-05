#!/bin/bash

sudo apt-get remove --auto-remove cloud-init -y
sudo apt-get purge --auto-remove cloud-init -y
rm -rf /etc/cloud
