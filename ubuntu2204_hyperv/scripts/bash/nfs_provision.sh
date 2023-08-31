#!/bin/bash

# Configuring an NFS Server on the first VM. All the other VMs are NFS clients.
# We can safely assume the first VM has always an IP: 192.169.0.11
# Look at the script: bash/configure_static_ip.sh for how IPs are assigned.
NO_NODE=$1
ENABLE_KUBERNETES=$2
IP_ADDRESS=$(hostname -i)

nfs_on_first_node () {
    echo "I'm on the first node... Configuring the NFS server ..."
    apt-get install -yq nfs-kernel-server
    mkdir -p /nfs/data
    mkdir -p /nfs/logs
    chown -R nobody:nogroup /nfs
    echo "/nfs/data  *(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
    echo "/nfs/logs  *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
    systemctl enable --now nfs-kernel-server
    exportfs -arv

    return 0
}

nfs_on_next_nodes () {
    echo "I'm on node $IP_ADDRESS ... Configuring NFS client"
    apt-get install -yq nfs-common
    showmount -e $1
    mkdir -p /mnt/nfs/data
    mkdir -p /mnt/nfs/logs
   
    mount -t nfs  $1:/nfs/data /mnt/nfs/data
    mount -t nfs  $1:/nfs/logs /mnt/nfs/logs
    echo "$1:/nfs/data     /mnt/nfs/data  nfs     defaults 0 0" >> /etc/fstab
    echo "$1:/nfs/logs     /mnt/nfs/logs  nfs     defaults 0 0" >> /etc/fstab

    return 0
}

skip_installation () {
    echo "Skipping node, we're on the load balancer".
    return 0
}

set +e
echo "NFS Provisioning."
if [ "$ENABLE_KUBERNETES" = "false" ]
then 
  if  [ $NO_NODE -eq 1 ] 
  then
      nfs_on_first_node
  else
      nfs_on_next_nodes 192.169.0.21
  fi
else
  if [ $NO_NODE -eq 1 ]
  then 
    skip_installation
  elif [ $NO_NODE  -eq 2 ]
  then 
    nfs_on_first_node
  else
    nfs_on_next_nodes 192.169.0.22
  fi
fi
