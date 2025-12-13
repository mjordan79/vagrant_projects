#!/usr/bin/env bash
set -euo pipefail

# User messages are green.
log() {
    echo -e "\e[32m[INFO]\e[0m $*"
}

# Provision Docker CE Stable on the Vagrant VM plus updates packages. 
log "Attempting to provision Docker and accessory software ...";

# First, cleanup eventual incompatible packages that might be already installed.
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc 
do
    apt-get purge -yq $pkg
done

# Add Docker's official GPG key
apt-get install -yq ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and its components.
apt-get update -yq && apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    usermod -aG docker vagrant && \
    systemctl enable --now docker && \
    docker version

log "Installing Docker Bash completion ..."
curl https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
