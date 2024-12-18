#!/bin/bash
set -eu

#Only root to should run setup
if [ $(whoami) == root ];then
	echo "$(whoami) is root user. Please use non-root user to execute this script"
	exit
fi

echo -e "${DEFAULT_USER_PASSWORD}" | sudo passwd ${DEFAULT_USER} --stdin

sudo dnf update -y
sudo dnf clean all
# sudo dnf dnf install -y docker
# sudo systemctl enable --now docker

echo "Rebooting system....."
# System reboot to cleanup the provisioning files
sudo systemctl reboot
