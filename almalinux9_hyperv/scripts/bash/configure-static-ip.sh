#!/usr/bin/env bash
echo "Setting static IP address for Hyper-V Environment" $1"...";

rm -f /etc/NetworkManager/system-connections/*
rm -f /etc/resolv.conf
sed -i --follow-symlinks 's/\#plugins=keyfile,ifcfg-rh/no-auto-default=*/g' /etc/NetworkManager/NetworkManager.conf

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
IPADDR=192.169.0.1$1
PREFIX=24
GATEWAY=192.169.0.1
DNS1=8.8.8.8
DNS2=8.8.4.4
IPV6_DISABLED=yes
EOF

# Find the UUID of the network interface with: nmcli connection show eth0 | grep connection.uuid
# connection.uuid: c3b6233f-a68c-4abb-9353-db2161af8d05
# connection.uuid: 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03