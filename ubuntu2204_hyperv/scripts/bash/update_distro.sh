#!/usr/bin/env bash
set -euo pipefail

UPDATE_DISTRO=$1

log() {
    echo -e "[INFO] $*"
}

error() {
    echo -e "[ERROR] $*" >&2
    exit 1
}

if [[ "$UPDATE_DISTRO" == "release" ]] || [[ "$UPDATE_DISTRO" == "full" ]]; then
    if [[ "$UPDATE_DISTRO" == "release" ]]; then
      log "User chose to release upgrade the distro. Doing a full upgrade first ..."
    else
      log "User chose to full upgrade the distro ..."
    fi
    apt-get update -qq -y && apt-get dist-upgrade -qq -y && apt-get autoremove --purge -qq -y && \
        apt-get autoclean -qq -y && apt-get clean -qq -y
elif [[ "$UPDATE_DISTRO" == "upgrade" ]]; then
    log "User chose to upgrade the distro ..."
    apt-get update -qq -y && apt-get upgrade -qq -y && apt-get autoremove --purge -qq -y && \
        apt-get autoclean -qq -y && apt-get clean -qq -y
elif [[ "$UPDATE_DISTRO" == "disabled" ]]; then
    log "User chose to DISABLE updates. Just updating the repo ..."
    apt-get update -qq -y
fi
