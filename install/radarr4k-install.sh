#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y sqlite3
msg_ok "Installed Dependencies"

msg_info "Installing Radarr"
mkdir -p /var/lib/radarr4k/
chmod 775 /var/lib/radarr4k/
$STD wget --content-disposition 'https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
$STD tar -xvzf Radarr.master.*.tar.gz
mv Radarr /opt
mv /opt/Radarr /opt/Radarr4k
chmod 775 /opt/Radarr4k
msg_ok "Installed Radarr4k"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/radarr4k.service
[Unit]
Description=Radarr4k Daemon
After=syslog.target network.target
[Service]
UMask=0002
Type=simple
ExecStart=/opt/Radarr4k/Radarr -nobrowser -data=/var/lib/radarr4k/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl -q daemon-reload
systemctl enable --now -q radarr4k
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf Radarr.master.*.tar.gz
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
