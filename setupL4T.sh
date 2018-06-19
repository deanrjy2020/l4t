#!/bin/bash

# 1, setup the display
# do it manually.

# 2, allow root login
sudo gedit /etc/ssh/sshd_config
# #PermitRootLogin prohibit-password
# PermitRootLogin yes

# 3, setup the psswd of the root, like: r, and restart
sudo passwd root
systemctl restart sshd
# 4, setup ip address
sudo dhclient

# 5, save the driver version and backup the original lib
echo "check the dirver version:"
(cd /usr/lib/aarch64-linux-gnu/tegra ; ls -l libnvidia-* )
read -p "input the driver version: " L4T_DRIVER_VERSION
echo $L4T_DRIVER_VERSION > /home/nvidia/driver_version.txt

mkdir /home/nvidia/driver_backup
sudo cp /usr/lib/aarch64-linux-gnu/tegra/libnvidia-* /home/nvidia/driver_backup/.
