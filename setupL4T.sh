#!/bin/bash

# set the color.
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' #no color

function ECHO () {
    echo -e ${GREEN}$*${NC}
}

function first_time_setup () 
{
    ECHO "1, setup the display, do it manually..."

    ECHO "2, allow root login. add the 'PermitRootLogin yes' in the file..."
    sudo gedit /etc/ssh/sshd_config
    # #PermitRootLogin prohibit-password
    # PermitRootLogin yes

    ECHO "3, setup the psswd of the root, like: 'r'..."
    sudo passwd root
    systemctl restart sshd

    ECHO "4, setup ip address..."
    sudo dhclient

    ECHO "5, save the driver version and backup the original lib..."
    ECHO "5.1, check the dirver version..."
    (cd /usr/lib/aarch64-linux-gnu/tegra ; ls -l libnvidia-* )
    read -p "5.2, input the driver version, e.g. 415.00: " L4T_DRIVER_VERSION
    echo $L4T_DRIVER_VERSION > ~/driver_version.txt
    ECHO "5.3, dirver version saved..."

    ECHO "5.4, backup the dirver version..."
    mkdir ~/driver_backup
    sudo cp /usr/lib/aarch64-linux-gnu/tegra/libnvidia-* ~/driver_backup/.

    ECHO "first time setup done."
}

function mount_host ()
{
    ECHO "mounting host..."

    # the user name will always be 'jiayuanr'
    read -p "input the IP of the host: " CODE_HOST_IP
    sudo chmod a+r /etc/fuse.conf
    ECHO "uncomment the 'user_allow_other' "
    sudo gedit /etc/fuse.conf

    # after this point, all you need to do is waiting.
    sudo dhclient # access the internet
    sudo apt update
    sudo apt install git sshfs -y

    # the local folder name.
    mkdir ~/mount
    #sshfs -o allow_other,idmap=user,reconnect,workaround=nodelaysrv jiayuanr@172.17.173.154:/home/jiayuanr/code/deva_L4T ~/mount
    sshfs -o allow_other,idmap=user,reconnect,workaround=nodelaysrv jiayuanr@${CODE_HOST_IP}:${CODE_PATH} ~/mount

    ECHO "mounting host done..."
}

function install_qtcreator ()
{
	ECHO "installing qtcreator..."
    sudo apt update
    sudo apt install qtcreator -y

    # we need this script for qtcreator debug.
	ECHO set substitute-path ${CODE_PATH} /home/nvidia/mount > ~/qt.sh

    ECHO "installing qtcreator done..."
}

read -p "first time setting up after flashing? 0 or 1: " FIRST_TIME
read -p "mount the host source code? 0 or 1: " MOUNT_HOST
read -p "need qt creator? 0 or 1: " QT_CREATOR
read -p "input the code path, e.g. /home/jiayuanr/code/deva_L4T : " CODE_PATH

if [ $FIRST_TIME == "1" ]
then
    first_time_setup
else
    ECHO "skip first time setting up."
fi

if [ $MOUNT_HOST == "1" ]
then
    mount_host
else
    ECHO "skip mountng host."
fi

if [ $FIRST_TIME == "1" ]
then
	# if you mount the source code, probably need qtcreator.
    # takes ~20 min
    install_qtcreator
else
    ECHO "skip installing qt creator."
fi