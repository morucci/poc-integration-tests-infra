#!/bin/bash

# Borrowed from https://github.com/lxc/lxc/blob/master/templates/lxc-ubuntu.in

set -ex

copy_configuration()
{
    path=$1
    rootfs=$2
    name=$3
    arch=$4
    release=$5

    if [ $arch = "i386" ]; then
        arch="i686"
    fi

    # if there is exactly one veth network entry, make sure it has an
    # associated hwaddr.
    nics=`grep -e '^lxc\.network\.type[ \t]*=[ \t]*veth' $path/config | wc -l`
    if [ $nics -eq 1 ]; then
        grep -q "^lxc.network.hwaddr" $path/config || sed -i -e "/^lxc\.network\.type[ \t]*=[ \t]*veth/a lxc.network.hwaddr = 00:16:3e:$(openssl rand -hex 3| sed 's/\(..\)/\1:/g; s/.$//')" $path/config
    fi

    # Generate the configuration file
    ## Create the fstab (empty by default)
    touch $path/fstab

    ## Relocate all the network config entries
    sed -i -e "/lxc.network/{w ${path}/config-network" -e "d}" $path/config

    ## Relocate any other config entries
    sed -i -e "/lxc./{w ${path}/config-auto" -e "d}" $path/config

    ## Add all the includes
    echo "" >> $path/config
    echo "# Common configuration" >> $path/config
    if [ -e "${LXC_TEMPLATE_CONFIG}/ubuntu.common.conf" ]; then
        echo "lxc.include = ${LXC_TEMPLATE_CONFIG}/ubuntu.common.conf" >> $path/config
    fi
    if [ -e "${LXC_TEMPLATE_CONFIG}/ubuntu.${release}.conf" ]; then
        echo "lxc.include = ${LXC_TEMPLATE_CONFIG}/ubuntu.${release}.conf" >> $path/config
    fi

    ## Add the container-specific config
    echo "" >> $path/config
    echo "# Container specific configuration" >> $path/config
    [ -e "$path/config-auto" ] && cat $path/config-auto >> $path/config && rm $path/config-auto
    grep -q "^lxc.rootfs" $path/config 2>/dev/null || echo "lxc.rootfs = $rootfs" >> $path/config
    cat <<EOF >> $path/config
lxc.mount = $path/fstab
lxc.utsname = $name
lxc.arch = $arch
EOF

    ## Re-add the previously removed network config
    echo "" >> $path/config
    echo "# Network configuration" >> $path/config
    cat $path/config-network >> $path/config
    rm $path/config-network

    if [ $? -ne 0 ]; then
        echo "Failed to add configuration"
        return 1
    fi

    return 0
}

LXC_TEMPLATE_CONFIG=/usr/share/lxc/config

[ -z "$1" ] && exit 1
name=$1

copy_configuration /var/lib/lxc/${name} /var/lib/lxc/${name}/rootfs $name x86_64 precise
