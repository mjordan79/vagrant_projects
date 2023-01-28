#!/usr/bin/env bash

# Based on ideas taken here: https://superuser.com/questions/1354658/hyperv-static-ip-with-vagrant
echo "Setting static IP address for Hyper-V Environment" $1"... 192.169.0.$(expr 20 + $1)";

# Static IP configuration (first VM will always have *.21 IP)
cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.169.0.$(expr 20 + $1)/24]
      gateway4: 192.169.0.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF

# Find the UUID of the network interface with: nmcli connection show eth0 | grep connection.uuid
# connection.uuid: c3b6233f-a68c-4abb-9353-db2161af8d05
# connection.uuid: 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03

#nmcli con add type ethernet con-name 'static-ip' ifname eth0 ipv4.method manual ipv4.addresses 192.169.0.21/24 gw4 192.169.1.1
#nmcli con mod static-ip ipv4.dns 192.169.1.1
#nmcli con up id 'static-ip'