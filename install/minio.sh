#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add newt
$STD apk add curl
$STD apk add openssh
$STD apk add vim
$STD apk add nano
$STD apk add mc
msg_ok "Installed Dependencies"

msg_info "Installing MinIO"
$STD apk add minio --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
sed -i 's/^MINIO_ROOT_USER=.*/MINIO_ROOT_USER="admin"/' /etc/conf.d/minio
sed -i 's/^MINIO_ROOT_PASSWORD=.*/MINIO_ROOT_PASSWORD="$PW"/' /etc/conf.d/minio
sed -i 's/^MINIO_ADDRESS=.*/MINIO_ADDRESS="0.0.0.0:9000"/' /etc/conf.d/minio
sed -i 's/^MINIO_CONSOLE_ADDRESS=.*/MINIO_CONSOLE_ADDRESS="0.0.0.0:9001"/' /etc/conf.d/minio
sed -i 's/^MINIO_BROWSER=.*/MINIO_BROWSER="on"/' /etc/conf.d/minio
rc-service minio restart
msg_ok "Installed MinIO"

motd_ssh
customize