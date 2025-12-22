#!/usr/bin/env bash

# Create a new netplan entry
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

sudo chmod 600 /etc/netplan/01-netcfg.yaml

# Hyper-V doesn't update the ARP table until it knows the assigned IP address. This doesn't happen until
# the VM doesn's send some network traffic. hyperv-kick.service force a DHCP renew, generates immediate traffic
# and the ARP table is immediately updated.
sudo tee /etc/systemd/system/hyperv-kick.service > /dev/null <<'EOF'
[Unit]
Description=Force DHCP renew so Hyper-V sees the IP
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/networkctl renew eth0

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hyperv-kick.service

# Apply the network plan configuration.
sudo netplan generate

# Ensure the networking interfaces get configured on boot.
sudo systemctl enable systemd-networkd.service
