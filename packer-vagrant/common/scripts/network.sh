#!/usr/bin/env bash

# Disable IPv6 for the current boot.
sudo sysctl net.ipv6.conf.all.disable_ipv6=1

# Ensure IPv6 stays disabled.
printf "\nnet.ipv6.conf.all.disable_ipv6 = 1\n" | sudo tee -a /etc/sysctl.conf > /dev/null

printf "ubuntu.localdomain\n" | sudo tee /etc/hostname > /dev/null
printf "\n127.0.0.1 ubuntu.localdomain\n\n" | sudo tee -a /etc/hosts > /dev/null

sudo tee /etc/netplan/01-netcfg.yaml > /dev/null <<'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: false
      optional: true
      nameservers:
        addresses: [4.2.2.1, 4.2.2.2, 208.67.220.220]
EOF

# Apply the network plan configuration.
sudo netplan generate

# Ensure a nameserver is being used that won't return an IP for non-existent domain names.
sudo sed -i -e "s/#DNS=.*/DNS=4.2.2.1 4.2.2.2 208.67.220.220/g" /etc/systemd/resolved.conf
sudo sed -i -e "s/#FallbackDNS=.*/FallbackDNS=/g" /etc/systemd/resolved.conf
sudo sed -i -e "s/#Domains=.*/Domains=/g" /etc/systemd/resolved.conf
sudo sed -i -e "s/#DNSSEC=.*/DNSSEC=yes/g" /etc/systemd/resolved.conf
sudo sed -i -e "s/#Cache=.*/Cache=yes/g" /etc/systemd/resolved.conf
sudo sed -i -e "s/#DNSStubListener=.*/DNSStubListener=yes/g" /etc/systemd/resolved.conf

# Install ifplugd so we can monitor and auto-configure nics.
sudo apt-get --assume-yes install ifplugd

# Configure ifplugd to monitor the eth0 interface.
sudo sed -i -e 's/INTERFACES=.*/INTERFACES="eth0"/g' /etc/default/ifplugd

# Ensure the networking interfaces get configured on boot.
sudo systemctl enable systemd-networkd.service

# Ensure ifplugd also gets started, so the ethernet interface is monitored.
sudo systemctl enable ifplugd.service
