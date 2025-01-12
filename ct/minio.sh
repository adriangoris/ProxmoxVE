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

  install_minio(){
    apk add minio --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
  }

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

  install_minio
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