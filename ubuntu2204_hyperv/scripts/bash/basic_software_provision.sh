#!/usr/bin/env bash
set -euo pipefail

# User messages are green.
log() {
    echo -e "\e[32m[INFO]\e[0m $*"
}

log "Attempting to install basic software ..."
apt-get update -qq -y && apt-get install -qq -y snapd net-tools policycoreutils policycoreutils-python-utils wget zip unzip && \
    localectl set-locale LANG=it_IT.UTF-8 && \
    sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="it"/' /etc/default/keyboard && \
    setupcon && apt-get autoclean -qq -y && apt-get autoremove -qq -y

