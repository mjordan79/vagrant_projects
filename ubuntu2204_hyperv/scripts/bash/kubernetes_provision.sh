#!/bin/bash

# Provision a Kubernetes node through MicroK8S and Snapd.
# Maintainer: Renato Perini <renato.perini@gmail.com>

NO_NODE=$1
KUBERNETES_VERSION=$2

microk8s_system_info() {
    echo "DNS configured for the machine:"
    resolvectl status
    echo "Content of the /etc/hosts file:"
    cat /etc/hosts
}

microk8s_install () {
    # Ensure the localhost alias is present in /etc/hosts
    sed -i '1s/.*/127.0.0.1 localhost/' /etc/hosts
    snap install microk8s --classic --channel=$1/stable
}

microk8s_certs () {
    # Insert the load balancer IP after the #MOREIPS line.
    sed -i '/^#MOREIPS/a IP.4 = 192.169.0.21' /var/snap/microk8s/current/certs/csr.conf.template
}

microk8s_refresh_interval () {
    # Replace the line --refresh-interval 30s with --refresh-interval 0s
    sed -i 's/^--refresh-interval 30s/--refresh-interval 0s/g' /var/snap/microk8s/current/args/apiserver-proxy
}

microk8s_iprange () {
    # Replace the line --service-cluster-ip-range=10.152.183.0/24 with --service-cluster-ip-range=10.152.183.0/16
    sed -i 's/^--service-cluster-ip-range=10.152.183.0\/24/--service-cluster-ip-range=10.152.183.0\/16/g' /var/snap/microk8s/current/args/kube-apiserver
}

echo "MicroK8S: Provisioning MicroK8S v$KUBERNETES_VERSION ..."
microk8s_system_info
microk8s_install $KUBERNETES_VERSION

# Waiting for ready state.
microk8s status -w

if [ $NO_NODE -eq 2 -o $NO_NODE -eq 3 -o $NO_NODE -eq 4 ]
then 
    echo "MicroK8S: on a Control Plane node. Configuring certs for v.$KUBERNETES_VERSION ..."
    microk8s_certs
    microk8s_refresh_interval
fi

microk8s_iprange
microk8s stop && microk8s start
