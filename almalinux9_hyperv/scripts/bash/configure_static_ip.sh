#!/usr/bin/env bash
echo "Setting static IP address for Hyper-V Environment" $1"... 192.169.0.$(expr 10 + $1)";

# Deleting this stuff so the network manager will recreate it. It is necessary otherwise the environment
# will take a huge load of time just to obtain a static IP address.
rm -f /etc/NetworkManager/system-connections/*
rm -f /etc/resolv.conf
sed -i --follow-symlinks 's/\#plugins=keyfile,ifcfg-rh/no-auto-default=*/g' /etc/NetworkManager/NetworkManager.conf

# No IPV6, please.
echo "Disabling IPV6 networking completely ..."
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.d/ipv6_disable.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.d/ipv6_disable.conf
sysctl --load /etc/sysctl.d/ipv6_disable.conf

# Static IP configuration (first VM will always have *.11 IP)
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
IPADDR=192.169.0.$(expr 10 + $1)
PREFIX=24
GATEWAY=192.169.0.1
DOMAIN=owgroup.it
DNS1=10.64.0.1
DNS2=8.8.8.8
DNS3=8.8.4.4
IPV6_DISABLED=yes
EOF

# Find the UUID of the network interface with: nmcli connection show eth0 | grep connection.uuid
# connection.uuid: c3b6233f-a68c-4abb-9353-db2161af8d05
# connection.uuid: 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03