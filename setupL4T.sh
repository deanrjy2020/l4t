#!/bin/bash

function first_time_setup () 
{
    echo "1, setup the display, do it manually..."

    echo "2, allow root login. add the 'PermitRootLogin yes' in the file..."
    sudo gedit /etc/ssh/sshd_config
    # #PermitRootLogin prohibit-password
    # PermitRootLogin yes

    echo "3, setup the psswd of the root, like: 'r'..."
    sudo passwd root
    systemctl restart sshd

    echo "4, setup ip address..."
    sudo dhclient

    echo "5, save the driver version and backup the original lib..."
    echo "5.1, check the dirver version..."
    (cd /usr/lib/aarch64-linux-gnu/tegra ; ls -l libnvidia-* )
    read -p "5.2, input the driver version: " L4T_DRIVER_VERSION
    echo $L4T_DRIVER_VERSION > /home/nvidia/driver_version.txt
    echo "5.3, dirver version saved..."

    echo "5.4, backup the dirver version..."
    mkdir /home/nvidia/driver_backup
    sudo cp /usr/lib/aarch64-linux-gnu/tegra/libnvidia-* /home/nvidia/driver_backup/.

    echo "first time setup done."
}

function mount_host ()
{
    echo "mounting host..."
    sudo dhclient # access the internet
    sudo apt update
    sudo apt install git sshfs -y
    sudo chmod a+r /etc/fuse.conf
    echo "uncomment the user_allow_other"
    sudo gedit /etc/fuse.conf

    mkdir mount

    #read -p "input the IP and code path"
    sshfs -o allow_other,idmap=user,reconnect,workaround=nodelaysrv jiayuanr@172.17.173.154:/home/jiayuanr/code/deva_L4T mount

    echo "mounting host done..."
}

read -p "first time setting up after flashing? 0 or 1" FIRST_TIME
read -p "mount the host source code? 0 or 1" MOUNT_HOST

if [ $FIRST_TIME == "1"]
then
    first_time_setup
else
    echo "skip first time setting up., "
fi

if [ $MOUNT_HOST == "1"]
then
    mount_host
else
    echo "skip mountng host., "
fi
