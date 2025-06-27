#!/bin/bash
set -eu

#Only root to should run setup
if [ $(whoami) == root ];then
	echo "$(whoami) is root user. Please use non-root user to execute this script"
	exit
fi

readonly CUSTOM_PROFILE=custom_profile_file
# Custom profile for user shell.
# User login profile based hardening
echo "HISTCONTROL=ignoreboth" | sudo tee /etc/profile.d/${CUSTOM_PROFILE}.sh

# # This doesn't work for non-privileged users
# echo '[ "root" != "$USER" -a -n "$SSH_TTY" ] \
# 	&& sudo journalctl _SYSTEMD_UNIT=sshd.service -n 1 --grep "Accepted publickey for $USER from" -o cat \
# 	&& wall "Logged in as non-root user: $USER"' | sudo tee -a /etc/profile.d/${CUSTOM_PROFILE}.sh

# # Terminate user session if user logs in using password instead of a public-key
# echo '[ "root" == "$USER" -a -n "$SSH_TTY" ] \
# 	&& sudo journalctl _SYSTEMD_UNIT=sshd.service -n 1 --grep "Accepted password for $USER from" -o cat \
# 	&& ( \
# 		wall "ALERT!:  Someone attempted ssh login as root user. Terminating root user session(s) for security..."; \
# 		pkill -KILL -u root\
# 	)' | sudo tee -a /etc/profile.d/${CUSTOM_PROFILE}.sh

# Update system packages
if [[ "debian" == "$(grep -E "^ID_LIKE=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')" ]]; then
	echo "${DEFAULT_USER}:${DEFAULT_USER_PASSWORD}" | sudo chpasswd
	sudo apt update && sudo apt upgrade -y && sudo apt autoclean && sudo apt autoremove
elif [[ "fedora" == "$(grep -E "^ID_LIKE=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')" ]]; then
	echo -e "${DEFAULT_USER_PASSWORD}" | sudo passwd ${DEFAULT_USER} --stdin
	sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove && sudo dnf clean all
else
	echo "INFO: Unidentified OS family"
fi

# Setup for S3 bucket mount
# wget https://s3.amazonaws.com/mountpoint-s3-release/latest/$(uname -p)/mount-s3.rpm
# sudo dnf install -y mount-s3.rpm
# sudo mkdir -p /mnt/s3bucket
# sudo mount-s3 s3bucketsaws<name of the bucket> /mnt/s3bucket

# Commented as this doesn't work for non-privileged users
# cat<<EOF >> /etc/systemd/system/user-login-gatekeeper.service
# [Unit]
# Description=Capture username on user login
# After=systemd-user-sessions.service

# [Service]
# ExecStart=/usr/local/bin/check_login_authentication.sh
# Type=oneshot
# User=root
# Environment=CURRENT_USER=%u
# Privileged=true

# [Install]
# WantedBy=multi-user.target
# EOF

# cat<<EOF >> /usr/local/bin/check_login_authentication.sh
# #!/bin/bash
# # filter for user login
# LOGGED_IN_USER=$(journalctl _SYSTEMD_UNIT=sshd.service -n 5 --grep "Accepted" | grep -oP 'sshd.*: Accepted password for \K\w[-\w]+' | tail -1)
# if [[ "${CURRENT_USER}" == "${LOGGED_IN_USER}" ]]; then
# 	wall "ALERT!:  Attempted ssh login as $CURRENT_USER user using password instead of publickey file. Terminating $CURRENT_USER user session(s)..."
# 	pkill -KILL -u $CURRENT_USER
# fi

# # journalctl _SYSTEMD_UNIT=sshd.service -n 10 --grep "Accepted" | grep -oP 'sshd.*: Accepted publickey for \K\w[-\w]+' | tail -1
# EOF
# echo '[ "root" != "$USER" -a -n "$SSH_TTY" ] && sudo systemctl start user-login-gatekeeper.service' | sudo tee -a /etc/profile.d/${CUSTOM_PROFILE}.sh

# # This rsyslod config is an alternative to journalctl query for sshd
# # This rsyslog config enables generation of /var/log/secure file
# dnf install -y rsyslog
# systemctl enable --now rsyslog
# echo 'SyslogFacility AUTH' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
# echo 'LogLevel INFO' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
# systemctl restart sshd


# sudo dnf dnf install -y docker
# sudo systemctl enable --now docker

# echo "Rebooting system....."
# # System reboot to cleanup the provisioning files
# sudo systemctl reboot
