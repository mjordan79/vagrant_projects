#!/bin/sh

# Provision Docker CE Stable on the Vagrant VM plus updates packages and enabes netfilter for Kubernetes. 
# Maintainer: Renato Perini <renato.perini@gmail.com>
yum update -y && yum install -y deltarpm yum-utils device-mapper-persistent-data lvm2 curl telnet \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && setenforce 0 \
    && sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux \
    && modprobe br_netfilter ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh \
    && echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.d/k8s.conf \
    && echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.d/k8s.conf \
    && sysctl --system \
    && yum install -y docker-ce \
    && systemctl enable docker \
    && sudo usermod -aG docker vagrant \
    && systemctl start docker
