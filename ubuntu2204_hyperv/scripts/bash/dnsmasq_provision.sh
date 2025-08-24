#!/bin/bash

NO_NODE=$1

dnsmasq_config_file () {
    echo "Writing config file in /etc/dnsmasq.conf ..."
    cat << EOF > /etc/dnsmasq.conf
# Listen on the load balancer IP
listen-address=127.0.0.1

# Don't handle DHCP requests
no-dhcp-interface=eth0

# Use the hosts file for DNS resolution
addn-hosts=/etc/dnsmasq.hosts

# Avoid conflicts with systemd-resolved
port=53

# Upstream DNS servers for external resolution
server=8.8.8.8
server=8.8.4.4
EOF
}

dnsmasq_hosts_file () {
    echo "Writing hosts file in /etc/dnsmasq.hosts ..."
    cat << EOF > /etc/dnsmasq.hosts
192.169.0.21 node-lb
192.169.0.22 node-master1
192.169.0.23 node-master2
192.169.0.24 node-master3
192.169.0.25 node-worker1
192.169.0.26 node-worker2
EOF
}

echo "Provisioning dnsmasq we're on the first node"

if [ "$NO_NODE" -eq 1 ] 
then 
    apt download dnsmasq
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
    rm -f /etc/resolv.conf
    echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
    dnsmasq_config_file
    dnsmasq_hosts_file
    dpkg --force-confold -i /home/vagrant/$(ls -t *.deb | head -n 1)
    rm -f /home/vagrant/$(ls -t *.deb | head -n 1)
    systemctl start dnsmasq
fi
