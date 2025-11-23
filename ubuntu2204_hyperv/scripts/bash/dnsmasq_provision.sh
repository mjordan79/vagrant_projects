#!/bin/bash

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
    echo "Writing hosts file in /etc/dnsmasq.hosts ..."
    for idx in "${!HOST_ARRAY[@]}"; do
      ip_suffix=$((21 + idx))   # computing the IP number
      echo "${BASE_IP}${ip_suffix} ${HOST_ARRAY[$idx]}" >> /etc/dnsmasq.hosts
    done
}

dnsmasq_config_file () {
    echo "Writing config file in /etc/dnsmasq.d/dnsmasq.conf ..."
    mkdir -p /etc/dnsmasq.d
    cat << EOF > /etc/dnsmasq.d/dnsmasq.conf
listen-address=127.0.0.1
domain=${MACHINE_INTERNAL_DOMAIN}
expand-hosts
no-resolv

# Don't handle DHCP requests
no-dhcp-interface=eth0

# Use the hosts file for DNS resolution
addn-hosts=/etc/dnsmasq.hosts

# Avoid conflicts with systemd-resolved, which answers on port 53
port=55

EOF
}

# Only for the first node.
networkd_split_dns_1() {
    cat << EOF > /etc/systemd/network/10-eth0.network
[Match]
Name=eth0

[Network]
Address=192.169.0.$((21 + NO_NODE - 1))/24
Gateway=192.169.0.1
DNS=127.0.0.1:55

Domains=~${MACHINE_INTERNAL_DOMAIN}
EOF
}

# Only for the nodes > 1. The split DNS points to the first node, where there is dnsmasq
networkd_split_dns_others() {
    cat << EOF > /etc/systemd/network/10-eth0.network
[Match]
Name=eth0

[Network]
Address=192.169.0.$((21 + NO_NODE - 1))/24
Gateway=192.169.0.1
DNS=${BASE_IP}21:55

Domains=~${MACHINE_INTERNAL_DOMAIN}
EOF
}

resolved_override() {
    mkdir -p /etc/systemd/resolved.conf.d
    cat << EOF > /etc/systemd/resolved.conf.d/cluster.conf
[Resolve]
DNS=1.1.1.1
FallbackDNS=1.0.0.1
Domains=~${MACHINE_INTERNAL_DOMAIN}
EOF
}

if [ "$NO_NODE" -eq 1 ] 
then
    echo "We're on the first node: provisioning dnsmasq, overriding systemd-resolved and configuring split DNS on systemd-networkd"
    apt download dnsmasq
    systemctl stop systemd-resolved
    # Create some configuration files and override some configs.
    dnsmasq_hosts_file
    dnsmasq_config_file
    networkd_split_dns_1
    resolved_override
    # Adjust the /etc/resolv.conf for pointing to the systemd-resolved stub
    rm -f /etc/resolv.conf
    ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    systemctl restart systemd-networkd
    systemctl start systemd-resolved
    # Install dnsmasq
    dpkg --force-confold -i /home/vagrant/$(ls -t *.deb | head -n 1)
    rm -f /home/vagrant/$(ls -t *.deb | head -n 1)
    # Restart the dns world
    systemctl restart systemd-networkd
    systemctl start systemd-resolved
    systemctl start dnsmasq
    # Make sure everything is clean
    resolvectl flush-caches
    resolvectl reset-server-features
    sleep 2
    # Print the configuration
    resolvectl status
else
    echo "Not on the first node: just overriding systemd-resolved and configuring split DNS on systemd-networkd"
    #systemctl stop resolved
    networkd_split_dns_others
    resolved_override
    # Adjust the /etc/resolv.conf for pointing to the systemd-resolved stub
    rm -f /etc/resolv.conf
    ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    systemctl restart systemd-networkd
    systemctl start systemd-resolved
    # Make sure everything is clean
    resolvectl flush-caches
    resolvectl reset-server-features
    sleep 2
    # Print the configuration
    resolvectl status
fi
