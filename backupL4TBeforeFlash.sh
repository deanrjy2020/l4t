#!/bin/bash

# set the color.
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' #no color

function ECHO_G () {
    echo -e ${GREEN}$*${NC}
}

function backup_as_needed () {
	# qt creator info
	scp /home/nvidia/.config/QtProject/qtcreator/*.qws jiayuanr@${CODE_HOST_IP}:/home/jiayuanr/bin/l4t_device_backup/
}

read -p "input the IP of the host: " CODE_HOST_IP

backup_as_needed
