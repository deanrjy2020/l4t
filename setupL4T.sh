#!/bin/bash

# set the color.
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' #no color

function ECHO_G () {
    echo -e ${GREEN}$*${NC}
}

#============================================================================
export HOST_IP=172.17.173.154
export HOST_NAME=jiayuanr
export CODE_PATH=/home/jiayuanr/code2/deva_l4t

# need this after flashing the device.
function dean_setup_l4t () {
    ECHO_G "******************************************"
    ECHO_G "******************************************"
    ECHO_G ""
    ECHO_G "1, setup the display, do it manually..."
    ECHO_G ""
    ECHO_G "******************************************"
    ECHO_G "******************************************"

    ECHO_G "2, allow root login. add the 'PermitRootLogin yes' in the file..."
    #sudo gedit /etc/ssh/sshd_config
    # #PermitRootLogin prohibit-password
    # PermitRootLogin yes
    echo 'PermitRootLogin yes' | sudo tee -a /etc/ssh/sshd_config

    ECHO_G "3, setup the psswd of the root, like: 'r'..."
    sudo passwd root
    systemctl restart sshd

    # no step 4.

    ECHO_G "5, save the driver version and backup the original lib..."
    ECHO_G "5.1, check the dirver version..."
    (cd /usr/lib/aarch64-linux-gnu/tegra ; ls -l libnvidia-* )
    read -p "5.2, input the driver version, e.g. 418.00: " L4T_DRIVER_VERSION
    echo $L4T_DRIVER_VERSION > ~/driver_version.txt
    ECHO_G "5.3, dirver version saved..."

    ECHO_G "5.4, backup the dirver version..."
    mkdir -p ~/driver_backup/tegra
    sudo cp /usr/lib/aarch64-linux-gnu/tegra/libnvidia-* ~/driver_backup/tegra/.
    mkdir -p ~/driver_backup/tegra-egl
    sudo cp /usr/lib/aarch64-linux-gnu/tegra-egl/* ~/driver_backup/tegra-egl/.

    # this is for ssh. scp still needs the passwd.
    ECHO_G "6, ssh key setup..."
    ssh-keygen
    # on your host, you also need to do "chmod 700 ~/.ssh/authorized_keys"
    cat ~/.ssh/id_rsa.pub | ssh ${HOST_NAME}@${HOST_IP} 'cat >> .ssh/authorized_keys'

    ECHO_G "7, install something..."
    sudo apt update
    sudo dhclient # access the internet
    sudo apt install sshfs -y # for mount the code.
    sudo apt install curl -y # for downloading qt color scheme.
    # setup git-cola
    sudo apt install git git-cola -y
    git config --global user.email "renjiayuan1314@gmail.com"
    git config --global user.name "Jiayuan Ren"

    ECHO_G "first time setup done."
}

function dean_backup_l4t () {
    # qt creator info
    scp /home/nvidia/.config/QtProject/qtcreator/*.qws ${HOST_NAME}@${HOST_IP}:/home/jiayuanr/bin/l4t_device_backup/
}

# need this after reboot. seems there is an issue with auto mount.
function dean_mount_host () {
    ECHO_G "mounting host..."

    sudo chmod a+r /etc/fuse.conf
    ECHO_G "adding the 'user_allow_other' to /etc/fuse.conf"
    #sudo gedit /etc/fuse.conf
    echo 'user_allow_other' | sudo tee -a /etc/fuse.conf

    # the local folder name.
    mkdir -p ~/mount
    #sshfs -o allow_other,idmap=user,reconnect,workaround=nodelaysrv jiayuanr@172.17.173.154:/home/jiayuanr/code2/deva_l4t ~/mount
    sshfs -o allow_other,idmap=user,reconnect,workaround=nodelaysrv ${HOST_NAME}@${HOST_IP}:${CODE_PATH} ~/mount

    ECHO_G "mounting host done..."
}

function dean_install_qtcreator () {
    ECHO_G "installing qtcreator..."
    # we need this script for qtcreator debug.
    echo set substitute-path ${CODE_PATH} /home/nvidia/mount > ~/qt.sh

    sudo apt update
    sudo apt install qtcreator -y

    sleep 1 s
    # launch qt creator
    qtcreator
    sleep 1 s

    ECHO_G "scp the qt creator qws files to device..."
    # I don't want to write my host passwd here. type it.
    scp ${HOST_NAME}@${HOST_IP}:/home/jiayuanr/bin/l4t_device_backup/*.qws /home/nvidia/.config/QtProject/qtcreator/

    # download the qt color scheme.
    # https://github.com/renjiayuan1314/qtcreator-custom
    curl https://raw.githubusercontent.com/busyluo/qtcreator-custom/master/setup.sh -sSf | sh

    ECHO_G "installing qtcreator done..."
}

# after flashing the device.
# source l4t/setupL4T.sh ; dean_source
function dean_source () {
    echo 'source /home/nvidia/l4t/setupL4T.sh' | tee -a /home/nvidia/.bashrc
}



