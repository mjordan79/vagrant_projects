#!/usr/bin/env bash
set -euo pipefail

UPDATE_DISTRO=$1

log() {
    echo -e "[INFO] $*"
}

skip() {
    echo -e "[SKIP] $*" >&2
    exit 0
}

force_update() {
    cat << EOF > /etc/apt/apt.conf.d/90force-conf
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
}
EOF
}

if [[ "$UPDATE_DISTRO" == "release" ]]; then
    CURRENT=$(lsb_release -rs)
    if [[ "$CURRENT" != "22.04" ]]; then
        skip "This script works only on Ubuntu 22.04 LTS (Jammy). Actual version: $CURRENT - Skipping upgrade."
    fi
    log "Actual version: $CURRENT - Release upgrade eligible ..."
    log "Continuing to release upgrade the distro. This might take a long time. Downloading ..."
    apt-get update -qq -y && apt-get dist-upgrade -qq -y
    apt-get install update-manager-core -qq -y
    sed -i 's/^Prompt=never/Prompt=lts/' /etc/update-manager/release-upgrades
    force_update
    export DEBIAN_FRONTEND=noninteractive
    do-release-upgrade -f DistUpgradeViewNonInteractive | tee /var/log/release-upgrade.log
    unset DEBIAN_FRONTEND
    #apt-get autoremove --purge -qq -y && apt-get autoclean -qq -y && apt-get clean -qq -y
fi
