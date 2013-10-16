#!/bin/bash

set -e
set -u
set -x

MURANO_RELEASE=${MURANO_RELEASE:-release-0.3}
DEVSTACK_RELEASE=${DEVSTACK_RELEASE:-stable/grizzly}
MURANO_IMG_NAME=${MURANO_IMG_NAME:-ws-2012-std.qcow2}
MURANO_IMG="/opt/${MURANO_IMG_NAME}"
MY_IP=$(hostname -I | cut -d' ' -f1)

export DEBIAN_FRONTEND=noninteractive


function install_packages {
  apt-get update 2>&1>/dev/null
  echo "Installing required packages"
  apt-get install -y build-essential python-pip python-dev libxml2-dev libxslt-dev libffi-dev git dos2unix
}

function configure_and_run_devstack {
  if ! [[ -e /opt/devstack ]]; then
    git clone https://github.com/openstack-dev/devstack.git /opt/devstack
  fi

  pushd /opt/devstack
  
  git checkout ${DEVSTACK_RELEASE}

  # Need to fixup the SHELL_AFTER_RUN line
  sed -i 's/source stack.sh/bash stack.sh/g' stack.sh

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

# Disable Tempest
#
disable_service tempest

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

function install_murano {
  local basedir="/opt/git"
  local murano_dir="${basedir}/murano-deployment"
  local murano_conf_dir="/etc/murano-deployment"

  if ! [[ -e ${basedir} ]]; then
    mkdir /opt/git
  fi

  if ! [[ -e ${murano_dir} ]]; then
    git clone https://github.com/stackforge/murano-deployment.git -b ${MURANO_RELEASE} ${murano_dir}
  fi

  if ! [[ -e ${murano_conf_dir} ]]; then
    mkdir ${murano_conf_dir}
  fi

  tee ${murano_conf_dir}/lab-binding.rc <<EOH
LAB_HOST='${MY_IP}'

ADMIN_USER='admin'
ADMIN_PASSWORD='secrete'

RABBITMQ_LOGIN='guest'
RABBITMQ_PASSWORD='rabbitpass'
RABBITMQ_VHOST=''
#RABBITMQ_HOST=''
#RABBITMQ_HOST_ALT=''

BRANCH_NAME='${MURANO_RELEASE}'

# Only 'true' or 'false' values are allowed!
SSL_ENABLED='false'
SSL_CA_FILE=''
SSL_CERT_FILE=''
SSL_KEY_FILE=''

#FILE_SHARE_HOST=''

#BRANCH_MURANO_API=''
#BRANCH_MURANO_DASHBOARD=''
#BRANCH_MURANO_CLIENT=''
#BRANCH_MURANO_CONDUCTOR=''
EOH

  pushd ${murano_dir}/devbox-scripts

  # this script expects to install openstack-dashboard packages, not from devstack
  sed -i 's|/usr/share/openstack-dashboard/openstack_dashboard/settings.py|/opt/stack/horizon/openstack_dashboard/settings.py|g' murano-git-install.sh 
  sed -i 184's/ openstack-dashboard//g' murano-git-install.sh

  if ! ( ./murano-git-install.sh prerequisites ); then
    echo "Something went wrong, please run the following command by hand."
    echo "  cd ${murano_dir}/devbox-scripts"
    echo "  ./murano-git-install.sh prerequisites"
    exit 1
  fi

  if ! [[ -e /var/log/murano-dashboard.log ]]; then
    touch /var/log/murano-dashboard.log
  fi
  chown stack /var/log/murano-dashboard.log

  if ! ( ./murano-git-install.sh install ); then
    echo "Something went wrong, please run the following command by hand."
    echo "  cd ${murano_dir}/devbox-scripts"
    echo "  ./murano-git-install.sh install"
    exit 1
  fi

  popd

  sed -i 's/swordfish/secrete/' /etc/murano-api/murano-api.conf
  dos2unix /etc/murano-conductor/conductor.conf
  sed -i 's|auth_url = |auth_url = http://${MY_IP}:5000/v2.0|g' /etc/murano-conductor/conductor.conf
  service murano-api restart
  service murano-conductor restart
}

function upload_cirros_image {
  local cirros_url="http://download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img"
  local tmpdir=$(mktemp -d)

  pushd ${tmpdir}
  wget -q ${cirros_url} -O cirros.img
  source /opt/devstack/openrc admin admin
  glance image-create --name "cirros-image" --is-public True --container-format bare --disk-format qcow2 --file cirros.img
  popd
  rm -rf ${tmpdir}
}

function check_for_murano_image {
  if ! [[ -e ${MURANO_IMG} ]]; then
    echo "Murano image not found. You will need to build a windows image and place the image at ${MURANO_IMG}"
    exit 1
  fi
}

function upload_murano_image {
  local tmpfile=$(mktemp)
  tee ${tmpfile} <<EOH
set -x

glance image-create --name "ws-2012-std" --is-public true \
--container-format bare --disk-format qcow2 \
--file ${MURANO_IMG} \
--property murano_image_info='{"type":"windows.2012", "title":"Windows Server 2012"}'
EOH
  chmod +x ${tmpfile}

  source /opt/devstack/openrc admin admin
  if ! ( glance image-list | grep ws-2012-std ); then
    if ! ( ${tmpfile} ); then
      echo "There was an error uploading the Murano windows image"
      exit 1
    fi
  fi
}

####################

install_packages
check_for_murano_image
configure_and_run_devstack
install_murano
#upload_cirros_image
upload_murano_image
