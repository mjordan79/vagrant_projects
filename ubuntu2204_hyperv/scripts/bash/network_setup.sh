#!/usr/bin/env bash
set -euo pipefail

# User messages are green.
log() {
    echo -e "\e[32m[INFO]\e[0m $*"
}

# Some parameters. Modify accordingly to the create-nat-hyperv-switch.ps1 script.
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)  # Find the network interface
STATIC_IP="192.169.0.$(expr 20 + $1)/24" # The static IP we're going to set
GATEWAY="192.169.0.1"       # Gateway
DNS1="1.1.1.1"              # Primary DNS
DNS2="8.8.8.8"              # Secondary DNS
NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

log "Configuring Netplan for $IFACE interface with static IP $STATIC_IP"

# Backup of the existing file.
if [ -f "$NETPLAN_FILE" ]; then
    cp "$NETPLAN_FILE" "${NETPLAN_FILE}.bak"
    log "Backup created in ${NETPLAN_FILE}.bak"
fi

# We clean the /etc/hosts.
cat /dev/null > /etc/hosts

# Write the new configuration
cat << EOF > "$NETPLAN_FILE"
network:
  version: 2
  ethernets:
    $IFACE:
      dhcp4: no
      dhcp6: no
      addresses:
        - $STATIC_IP
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [$DNS1, $DNS2]
EOF

# Fix permissions on netplan files
sudo chmod 600 /etc/netplan/*.yaml
sudo chown root:root /etc/netplan/*.yaml

# Apply the final configuration
netplan apply

log "Network configuration for static IP applied"
