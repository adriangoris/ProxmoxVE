#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 agoris
# Author: agoris (agoris)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
.___  ___.  __  .__   __.  __    ______   
|   \/   | |  | |  \ |  | |  |  /  __  \  
|  \  /  | |  | |   \|  | |  | |  |  |  | 
|  |\/|  | |  | |  . `  | |  | |  |  |  | 
|  |  |  | |  | |  |\   | |  | |  `--'  | 
|__|  |__| |__| |__| \__| |__|  \______/  
                                          

EOF
}
header_info
echo -e "Loading..."
APP="MinIO"
var_disk="4"
var_cpu="2"
var_ram="1024"
var_os="alpine"
var_version="3.19"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW="-password alpine"
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
  UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 1 \
  "1" "Check for Alpine Updates" ON \
  3>&1 1>&2 2>&3)

  header_info
  if [ "$UPD" == "1" ]; then
    apk update && apk upgrade
  fi

  if [[ ! -d /usr/bin/minio ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  update_config_variables(){
    sed -i 's/^MINIO_ROOT_USER=.*/MINIO_ROOT_USER="admin"/' /etc/conf.d/minio
    sed -i 's/^MINIO_ROOT_PASSWORD=.*/MINIO_ROOT_PASSWORD="$PW"/' /etc/conf.d/minio
    sed -i 's/^MINIO_ADDRESS=.*/MINIO_ADDRESS="0.0.0.0:9000"/' /etc/conf.d/minio
    sed -i 's/^MINIO_CONSOLE_ADDRESS=.*/MINIO_CONSOLE_ADDRESS="0.0.0.0:9001"/' /etc/conf.d/minio
    sed -i 's/^MINIO_BROWSER=.*/MINIO_BROWSER="on"/' /etc/conf.d/minio
  }

  stop_mino() {
    if which rc-service 2>/dev/null >/dev/null; then
      echo "Stopping MinIO..."
      rc-service minio stop
    else
      echo "Skipped stopping MinIO, no rc-service found"
    fi
  }

  start_mino() {
    if which rc-service 2>/dev/null >/dev/null; then
      echo "Starting MinIO..."
      rc-service minio start
    else
      echo "Skipped starting MinIO, no rc-service found"
    fi
  }

  stop_mino
  update_config_variables
  start_mino

  echo "Done!"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"