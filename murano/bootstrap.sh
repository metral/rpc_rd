#!/bin/bash

set -e
set -u
set -x

export DEBIAN_FRONTEND=noninteractive

function install_packages {
  apt-get update 2>&1>/dev/null
  echo "Installing required packages"
  apt-get install -y build-essential python-pip python-dev libxml2-dev libxslt-dev libffi-dev git 
}

function configure_devstack {
  if ! [[ -e /opt/devstack ]]; then
    git clone https://github.com/openstack-dev/devstack.git /opt/devstack
  fi

  pushd /opt/devstack
  
  git checkout stable/grizzly

  # figure out the systems primary IP
  MY_IP=$(hostname -I | cut -d' ' -f1)

  tee /opt/devstack/localrc <<EOH
ADMIN_PASSWORD=secrete
MYSQL_PASSWORD=mysqlpass
RABBIT_PASSWORD=rabbitpass
SERVICE_PASSWORD=servicepass
SERVICE_TOKEN=sometoken

HOST_IP=${MY_IP}

FIXED_RANGE=192.168.100.0/24
FLAT_INTERFACE=eth1
PUBLIC_INTERFACE=eth0

# Don't drop into stack user shell
#
SHELL_AFTER_RUN=no

# Enable MySQL backend explicitily
#
DATABASE_TYPE=mysql

# Enable Heat
#
ENABLED_SERVICES+=,heat,h-api,h-api-cfn,h-api-cw,h-eng

# Add Fedora 17 image for load balancer
#
IMAGE_URLS+=",http://fedorapeople.org/groups/heat/prebuilt-jeos-images/F17-x86_64-cfntools.qcow2"

# Disable check of API requests rate
#
API_RATE_LIMIT=False

# Set NoopFirewallDriver to disable anti-spoofing rules
#
LIBVIRT_FIREWALL_DRIVER=nova.virt.firewall.NoopFirewallDriver

# Extra options for nova.conf
#
EXTRA_OPTS=(force_config_drive=true libvirt_images_type=qcow2 force_raw_images=false)
EOH

  if ! [[ -e local.sh ]]; then
    wget -q https://raw.github.com/stackforge/murano-deployment/release-0.3/getting-started/local.sh
  fi

  echo "***** RUNNING DEVSTACK *****"
  ./stack.sh
  #$(exit)
  popd
}

function install_and_configure_samba {
  # Configure user security
  sed -i 's/#   security = user/   security = user/g' /etc/samba/smb.conf 

  # Configure the image-builder-share
  if ! ( grep "\[image-builder-share\]" /etc/samba/smb.conf ); then
    cat >> /etc/samba/smb.conf <<EOH
[image-builder-share]
   comment = Murano Image Builder Share
   path = /opt/image-builder/share
   browsable = yes
   guest ok = yes
   guest account = nobody
   read only = no
   create mask = 0755
EOH
  fi
  echo "Restarting smbd"
  restart smbd 2>&1 >/dev/null
  echo "Restarting nmbd"
  restart nmbd 2>&1 >/dev/null
}

install_packages
configure_devstack
#install_and_configure_samba
