#!/usr/bin/env bash
echo "Setting static IP address for Hyper-V Environment" $1"...";

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
NAME=eth0
BOOTPROTO=none
ONBOOT=yes
PREFIX=24
IPADDR=192.169.0.1$1
GATEWAY=192.169.0.1
SUBNET_MASK=255.255.255.0
DNS1=8.8.8.8
IPV6INIT=no
EOF
