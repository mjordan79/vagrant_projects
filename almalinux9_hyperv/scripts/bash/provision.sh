#!/usr/bin/env bash

# Provision Docker CE Stable on the Vagrant VM plus updates packages and enabes netfilter for Kubernetes. 
# Maintainer: Renato Perini <renato.perini@gmail.com>
# echo "Restarting the network interface..."
# ip link set eth0 up
echo "Attempting to provision Docker and accessory software ...";
dnf install -yq epel-release && \
dnf update -yq && dnf install -yq vim htop net-tools curl telnet tmux bash-completion neofetch \
    && dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
    && setenforce 0 \
    && sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux \
    && systemctl disable --now firewalld \
    && dnf install -yq docker-ce docker-ce-cli docker-compose-plugin \
    && sudo usermod -aG docker vagrant \
    && systemctl enable --now docker
