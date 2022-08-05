#!/usr/bin/env bash

# Provision Docker CE Stable on the Vagrant VM plus updates packages. 
echo "Attempting to provision Docker and accessory software ...";
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
    && dnf install -yq docker-ce docker-ce-cli docker-compose-plugin \
    && sudo usermod -aG docker vagrant \
    && systemctl enable --now docker
echo "Installing Docker Bash completion ..."
curl https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
