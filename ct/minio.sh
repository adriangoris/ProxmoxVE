#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 agoris
# Author: agoris (agoris)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

# App Default Values
APP="MinIO"
var_tags="alpine;minio;s3;storage"
var_disk="4"
var_cpu="1"
var_ram="1024"
var_os="alpine"
var_version="3.19"
var_unprivileged="0"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
  if ! apk -e info newt >/dev/null 2>&1; then
    apk add -q newt
  fi
  while true; do

    CHOICE=$(
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 1 \
      "1" "Check for MinIO Updates" ON \
      3>&1 1>&2 2>&3
    )
    exit_status=$?
    if [ $exit_status == 1 ]; then
      clear
      exit-script
    fi
    header_info
    case $CHOICE in
    1)
      apk update && apk upgrade
      exit
      ;;
    esac
  done


  echo "Done!"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
