#!/bin/bash


set -ex

DIB=disk-image-create
WORKDIR=/var/cache/int_tests
BASE_IMAGES=$WORKDIR/bases
BASE_LXC=/var/lib/lxc

BASE_DISTS="precise trusty"

function install_req {
  sudo yum install -y lxc lxc-devel lxc-templates git python-pip
  sudo pip install ansible
  [ ! -d /tmp/diskimage-builder ] && {
    git clone https://github.com/openstack/diskimage-builder /tmp/diskimage-builder
    pushd /tmp/diskimage-builder
    sudo python setup.py install
    popd
  } || echo "diskimage-builder already installed"
  [ ! -d /tmp/python2-lxc ] && {
    # required by ansible-lxc
    git clone https://github.com/lxc/python2-lxc.git /tmp/python2-lxc
    pushd /tmp/python2-lxc
    sudo python setup.py install
    popd
  } || echo "python2-lxc already installed"
}

function setup_overlay {
  sudo mkdir -p /var/lib/overlay_dir/
}

function get_dist {
  local dist=$1
  DIB_RELEASE=$dist $DIB -a amd64 -t tar -o ubuntu-amd64 ubuntu
  sudo mv ubuntu-amd64.tar $BASE_IMAGES/${1}.tar
  [ -d $BASE_IMAGES/$1 ] && sudo rm -Rf $BASE_IMAGES/$1
  sudo mkdir $BASE_IMAGES/$1 && sudo tar -xf $BASE_IMAGES/${1}.tar -C $BASE_IMAGES/$1
}

function adapt_dist {
  local dist=$1
  pushd $BASE_IMAGES/$1
  sudo rm -Rf dev
  # LXC will populate dev/ at startup
  sudo mkdir sys proc dev
  popd
}

[ ! -d $WORKDIR ] && sudo mkdir $WORKDIR
[ ! -d $BASE_IMAGES ] && sudo mkdir $BASE_IMAGES
[ ! -d $BASE_LXC ] && sudo mkdir $BASE_LXC

install_req
setup_overlay

for dist in $BASE_DISTS; do
  get_dist $dist
  adapt_dist $dist
done

# Disable SELinux because it does not support overlayfs yet
grep -q SELINUX=disabled /etc/selinux/config || {
    sudo sed -i -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    echo "reboot to disable selinux now"
}
