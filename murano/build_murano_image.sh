#!/bin/bash

set -e
set -u
set -x

export DEBIAN_FRONTEND=noninteractive
RELEASE="release-0.3"
WIN_ISO_NAME="ws-2012-eval.iso"
WIN_ISO_PATH="/opt/${WIN_ISO_NAME}"

function install_packages {
  apt-get update 2>&1>/dev/null
  echo "Installing required packages"
  # apt-get install -y samba build-essential python-pip python-dev libxml2-dev libxslt-dev libffi-dev git zip virtinst qemu-kvm libvirt-bin qemu-utils
  apt-get install -y samba build-essential python-pip python-dev libxml2-dev libxslt-dev libffi-dev git zip virtinst qemu-kvm 
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

function checkout_deployment_repo {
  local repo_name="murano-deployment"
  local basedir="/opt/git"
  local repo_dir="${basedir}/${repo_name}"

  if ! [[ -e ${basedir} ]]; then
    mkdir /opt/git
  fi

  if ! [[ -e ${repo_dir} ]]; then
    git clone git://github.com/stackforge/${repo_name}.git ${basedir}/${repo_name}
  fi

  echo "Checking out BRANCH: ${RELEASE}"
  pushd ${repo_dir}
  git checkout ${RELEASE}
  popd

  pushd ${repo_dir}/image-builder

  # fix a bug in the dependency.list file
  if ! ( grep "name = MuranoAgent.zip" dependency.list ); then
    sed -i 's/\[Murano Agent\]/\[Murano Agent\]\nname = MuranoAgent.zip/g' dependency.list
  fi

  # fixup Far Manager
  sed -i 28's/true/false/g' dependency.list

  # fix up Sysinternals
  sed -i 39's/true/false/g' dependency.list
  sed -i 's/sysinternals_suite.zip/SysinternalsSuite.zip/g' dependency.list

  # fix up mSysGit
  sed -i 's/msysgit-1.8.3.exe/Git-1.8.1.2-preview20130201.exe/g' dependency.list

  # We are not concerned about win 2008
  sed -i 10's/true/false/g' dependency.list

  if ! ( make build-root ); then
    echo "Something went wrong, please run the following by hand."
    echo "  cd ${repo_dir}/image-builder"
    echo "  make build-root"
    exit 1
  fi 

  grab_additional_image_builder_deps

  if ! ( make test-build-files ); then
    echo "Something went wrong, please run the following by hand."
    echo "  cd ${repo_dir}/image-builder"
    echo "  make test-build-files"
    exit 1
  fi

  make ws-2012-std

  popd
}

function check_for_windows_iso {
  if ! [[ -e ${WIN_ISO_PATH} ]]; then
    echo "You need to download the Windows Server 2012 Evaluation iso."
    echo "  Grab it from http://technet.microsoft.com/en-us/evalcenter/hh670538.aspx"
    echo "Once downloaded place it at ${WIN_ISO_PATH}"
    exit 1
  fi
}

function grab_additional_image_builder_deps {
  local basedir=/opt/image-builder
  local imgdir=${basedir}/libvirt/images
  local filedir=${basedir}/share/files

  if ! [[ -e ${imgdir}/${WIN_ISO_NAME} ]]; then
    cp ${WIN_ISO_PATH} ${imgdir}
  fi

  local powershell_v3_file="Windows6.1-KB2506143-x64.msu"
  if ! [[ -e ${filedir}/${powershell_v3_file} ]]; then
    wget --directory-prefix=${filedir} http://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/${powershell_v3_file}
  fi

  local dotnet_40_file="dotNetFx40_Full_x86_x64.exe"
  if ! [[ -e ${filedir}/${dotnet_40_file} ]]; then
    wget --directory-prefix=${filedir} http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/${dotnet_40_file}
  fi

  local dotnet_45_file="dotNetFx45_Full_setup.exe"
  if ! [[ -e ${filedir}/${dotnet_45_file} ]]; then
    wget --directory-prefix=${filedir} http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/${dotnet_45_file}
  fi

  #local far_file=Far30b3525.x64.20130717.msi
  #if ! [[ -e ${filedir}/${far_file} ]]; then
  #  wget --directory-prefix=${filedir} http://www.farmanager.com/files/${far_file}
  #fi

}

check_for_windows_iso
install_packages
install_and_configure_samba
checkout_deployment_repo
