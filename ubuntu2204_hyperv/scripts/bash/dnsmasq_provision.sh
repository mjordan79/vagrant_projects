#!/usr/bin/env bash
set -euo pipefail

NO_NODE=$1
DOMAINS_LIST=$2
MACHINE_INTERNAL_DOMAIN=$3

# Remember, our IPs always start from *.21 for the first environment
BASE_IP="192.169.0."

dnsmasq_hosts_file () {
    IFS=',' read -r -a HOST_ARRAY <<< "$DOMAINS_LIST"

    # Creating / rewriting the dnsmasq.hosts file
    touch /etc/dnsmasq.hosts

    # Loop on hostnames
    echo "[INFO] Writing hosts file in /etc/dnsmasq.hosts ..."
    for idx in "${!HOST_ARRAY[@]}"; do
      ip_suffix=$((21 + idx))   # computing the IP number
      echo "${BASE_IP}${ip_suffix} ${HOST_ARRAY[$idx]}" >> /etc/dnsmasq.hosts
    done
}

dnsmasq_config_file () {
    echo "[INFO] Writing config file in /etc/dnsmasq.d/dnsmasq.conf ..."
    mkdir -p /etc/dnsmasq.d
    cat << EOF > /etc/dnsmasq.d/dnsmasq.conf
listen-address=${BASE_IP}21
bind-dynamic
expand-hosts
no-resolv
log-queries

# Authoritative for ${MACHINE_INTERNAL_DOMAIN}
domain=${MACHINE_INTERNAL_DOMAIN}
auth-server=${MACHINE_INTERNAL_DOMAIN}
auth-zone=${MACHINE_INTERNAL_DOMAIN}
local=/${MACHINE_INTERNAL_DOMAIN}/
mx-host=${MACHINE_INTERNAL_DOMAIN},mail.${MACHINE_INTERNAL_DOMAIN},10
txt-record=${MACHINE_INTERNAL_DOMAIN},"internal dns zone"

# Don't handle DHCP requests
no-dhcp-interface=eth0

# Use the hosts file for DNS resolution
addn-hosts=/etc/dnsmasq.hosts

# Avoid conflicts with systemd-resolved, which answers on port 53
port=55

EOF
}

# Local (eth0) DNS resolution, points to the dnsmasq DNS server.
networkd_split_dns() {
    cat << EOF > /etc/systemd/network/10-eth0.network
[Match]
Name=eth0

[Network]
Address=192.169.0.$((21 + NO_NODE - 1))/24
Gateway=192.169.0.1
DNS=${BASE_IP}21:55

# ~ = conditional routing, don't add suffixes but enables split dns.
Domains=~${MACHINE_INTERNAL_DOMAIN}
EOF
}

resolved_override_config() {
    # First, reset the DNS and FallbackDNS in /etc/systemd/resolved.conf
    #sed -i 's/^DNS=.*/DNS=8.8.8.8/g' /etc/systemd/resolved.conf
    #sed -i 's/^FallbackDNS=.*/FallbackDNS=8.8.4.4/g' /etc/systemd/resolved.conf
    sed -i 's/^DNS=.*/DNS=/g' /etc/systemd/resolved.conf
    sed -i 's/^FallbackDNS=.*/FallbackDNS=/g' /etc/systemd/resolved.conf
    # Then we create an ovverride
    mkdir -p /etc/systemd/resolved.conf.d
    cat << EOF > /etc/systemd/resolved.conf.d/cluster.conf
[Resolve]
DNS=1.1.1.1
FallbackDNS=1.0.0.1

# Search domain (without ~).
# If FQDN, resolution is first tried with DNS. If resolution fails, it will be expanded with .${MACHINE_INTERNAL_DOMAIN}
Domains=${MACHINE_INTERNAL_DOMAIN}
EOF
}

if [ "$NO_NODE" -eq 1 ] 
then
    echo "[INFO] We're on the first node: provisioning dnsmasq, overriding systemd-resolved and configuring split DNS on systemd-networkd"
    #apt-get download dnsmasq
    systemctl stop systemd-resolved
    # Create some configuration files and override some configs.
    dnsmasq_hosts_file
    dnsmasq_config_file
    networkd_split_dns
    resolved_override_config
    # Adjust the /etc/resolv.conf for pointing to the systemd-resolved stub
    rm -f /etc/resolv.conf
    ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    systemctl daemon-reload
    systemctl restart systemd-networkd
    systemctl start systemd-resolved
    # Install dnsmasq
    apt-get install -qq -y dnsmasq
    #dpkg --force-confold -i /home/vagrant/$(ls -t *.deb | head -n 1)
    #rm -f /home/vagrant/$(ls -t *.deb | head -n 1)
    # Restart the dns world
    systemctl restart systemd-networkd
    systemctl start systemd-resolved
    systemctl enable dnsmasq --now
    # Print the configuration
    systemctl restart systemd-resolved
    resolvectl status
else
    echo "[INFO] Not on the first node: just overriding systemd-resolved and configuring split DNS on systemd-networkd"
    systemctl stop systemd-resolved
    systemctl stop systemd-networkd.socket systemd-networkd
    networkd_split_dns
    resolved_override_config
    # Adjust the /etc/resolv.conf for pointing to the systemd-resolved stub
    rm -f /etc/resolv.conf
    ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    systemctl daemon-reload
    systemctl enable systemd-networkd.socket systemd-networkd --now
    systemctl enable systemd-resolved --now
    # Print the configuration
    systemctl restart systemd-resolved
    resolvectl status
fi
