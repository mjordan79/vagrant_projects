#!/usr/bin/env bash

# Provision Docker CE Stable on the Vagrant VM plus updates packages. 
echo "Attempting to provision Docker and accessory software ...";
#dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
#    && dnf install -yq docker-ce docker-ce-cli docker-compose-plugin \
#    && sudo usermod -aG docker vagrant \
#    && systemctl enable --now docker

apt install -yq ca-certificates curl gnupg lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update -yq && \
    apt install -yq docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
    usermod -aG docker vagrant && \
    systemctl enable --now docker

echo "Installing Docker Bash completion ..."
curl https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
