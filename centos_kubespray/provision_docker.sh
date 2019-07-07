#!/bin/sh

# Provision Docker CE Stable on the Vagrant VM
# Maintainer: Renato Perini <renato.perini@gmail.com>
yum update -y && yum install -y deltarpm yum-utils device-mapper-persistent-data lvm2 curl telnet \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && setenforce 0 \
    && sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux \
	&& yum install -y docker-ce \
    && systemctl enable docker \
    && sudo usermod -aG docker vagrant \
    && systemctl start docker
