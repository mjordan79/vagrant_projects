#!/usr/bin/env bash
set -euo pipefail

# Configuring an NFS Server on the first VM. All the other VMs are NFS clients.
# The first VM depends by the fact enable_kubernetes is set or not. If set, the 
# first node is 192.169.0.22. Otherwise it is 192.169.0.21
# Look at the script: bash/network_setup.sh for how IPs are assigned.
NO_NODE=$1
ENABLE_KUBERNETES=$2
ENABLE_RANCHER2_NODE=$3
IP_ADDRESS=$(hostname -i)

nfs_install_server() {
    echo "[INFO] I'm on the first node... Configuring the NFS server ..."
    apt-get install -qq -y nfs-kernel-server
    mkdir -p /nfs/data
    mkdir -p /nfs/logs
    chown -R nobody:nogroup /nfs
    echo "/nfs/data  *(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
    echo "/nfs/logs  *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
    systemctl enable --now nfs-kernel-server
    exportfs -arv

    return 0
}

# Be aware: here $1 is not the global parameter but the parameter passed to the function.
nfs_install_client () {
    echo "[INFO] I'm on node $IP_ADDRESS ... Configuring NFS client ..."
    apt-get install -qq -y nfs-common
    showmount -e $1
    mkdir -p /mnt/nfs/data
    mkdir -p /mnt/nfs/logs
   
    mount -t nfs $1:/nfs/data /mnt/nfs/data
    mount -t nfs $1:/nfs/logs /mnt/nfs/logs
    echo "$1:/nfs/data     /mnt/nfs/data  nfs     defaults 0 0" >> /etc/fstab
    echo "$1:/nfs/logs     /mnt/nfs/logs  nfs     defaults 0 0" >> /etc/fstab

    return 0
}

skip_installation () {
    echo "[INFO] Skipping node, we're on the load balancer ...".
    return 0
}

echo "[INFO] NFS Provisioning ..."
if [[ "$ENABLE_KUBERNETES" == "false" ]]; then
  if  [[ "$NO_NODE" -eq 1 ]]; then
      nfs_install_server
  else
      # Specify the NFS Server IP for the NFS client.
      nfs_install_client 192.169.0.21
  fi
elif [[ "$ENABLE_KUBERNETES" == "true" ]] && [[ "$ENABLE_RANCHER2_NODE" == "false" ]]; then
  if [[ "$NO_NODE" -eq 1 ]]; then
    skip_installation
  elif [[ "$NO_NODE" -eq 2 ]]; then
    nfs_install_server
  else
    # Specify the NFS Server IP for the NFS client.
    nfs_install_client 192.169.0.22
  fi
elif [[ "$ENABLE_KUBERNETES" == "true" ]] && [[ "$ENABLE_RANCHER2_NODE" == "true" ]]; then
  if [[ "$NO_NODE" -eq 1 || "$NO_NODE" -eq 2 ]]; then
    skip_installation
  elif [[ "$NO_NODE" -eq 3 ]]; then
    nfs_install_server
  else
    # Specify the NFS Server IP for the NFS client.
    nfs_install_client 192.169.0.23
  fi
fi
