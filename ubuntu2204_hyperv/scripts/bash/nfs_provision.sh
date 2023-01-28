#!/bin/bash

# Configuring an NFS Server on the first VM. All the other VMs are NFS clients.
# We can safely assume the first VM has always an IP: 192.169.0.11
# Look at the script: bash/configure_static_ip.sh for how IPs are assigned.
NO_NODE=$1

echo "NFS Provisioning."
if [ $NO_NODE -eq 1 ] 
then
    echo "I'm on the first node... Configuring the NFS server ..."
    apt-get install -yq nfs-kernel-server
    mkdir -p /nfs/data
    mkdir -p /nfs/logs
    chown -R nobody:nogroup /nfs
    echo "/nfs/data  *(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
    echo "/nfs/logs  *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
    systemctl enable --now nfs-kernel-server
    exportfs -arv
else
    echo "I'm on node 192.169.0.$(expr 20 + $NO_NODE) ... Configuring NFS client"
    apt-get install -yq nfs-common
    showmount -e 192.169.0.21
    mkdir -p /mnt/nfs/data
    mkdir -p /mnt/nfs/logs
   
    mount -t nfs  192.169.0.21:/nfs/data /mnt/nfs/data
    mount -t nfs  192.169.0.21:/nfs/logs /mnt/nfs/logs
    echo "192.169.0.21:/nfs/data     /mnt/nfs/data  nfs     defaults 0 0" >> /etc/fstab
    echo "192.169.0.21:/nfs/logs     /mnt/nfs/logs  nfs     defaults 0 0" >> /etc/fstab
fi
