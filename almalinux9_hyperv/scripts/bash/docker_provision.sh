#!/usr/bin/env bash

# Provision Docker CE Stable on the Vagrant VM plus updates packages. 
echo "Attempting to provision Docker and accessory software ...";
dnf install -yq epel-release && \
dnf update -yq && dnf install -yq vim htop net-tools curl telnet tmux xorg-x11-xauth bash-completion neofetch \
    && dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
    && dnf install -yq docker-ce docker-ce-cli docker-compose-plugin \
    && sudo usermod -aG docker vagrant \
    && systemctl enable --now docker