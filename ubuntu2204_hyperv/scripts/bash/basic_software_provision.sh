#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Attempting to install basic software ..."
apt-get update -qq -y && apt-get install -qq -y snapd net-tools policycoreutils policycoreutils-python-utils wget zip unzip && \
    localectl set-locale LANG=it_IT.UTF-8 && \
    sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="it"/' /etc/default/keyboard && \
    setupcon && apt-get autoclean -qq -y && apt-get autoremove -qq -y

