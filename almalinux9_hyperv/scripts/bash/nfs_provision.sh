#!/bin/bash

# Configuring an NFS Server on the first VM. All the other VMs are NFS clients.
# We can safely assume the first VM has always an IP: 192.169.0.11
# Look at the script: bash/configure_static_ip.sh for how IPs are assigned.
NO_NODE=$1

echo "NFS Provisioning."
if [ $NO_NODE -eq 1 ] 
then
    echo "I'm on the first node... Configuring the NFS server ..."
    dnf install -yq nfs-utils
    mkdir -p /nfs/data
    mkdir -p /nfs/logs
    chown -R nobody:nobody /nfs
    echo "/nfs/data  *(rw,sync,no_all_squash,root_squash)" > /etc/exports
    echo "/nfs/logs  *(rw,sync,no_all_squash,root_squash)" >> /etc/exports
    systemctl enable --now nfs-server
    exportfs -arv
else
    echo "I'm on node 192.169.0.$(expr 10 + $NO_NODE) ... Configuring NFS client"
    dnf install -yq nfs-utils nfs4-acl-tools
    showmount -e 192.169.0.11
    mkdir -p /mnt/nfs/data
    mkdir -p /mnt/nfs/logs
   
    mount -t nfs  192.169.0.11:/nfs/data /mnt/nfs/data
    mount -t nfs  192.169.0.11:/nfs/logs /mnt/nfs/logs
    echo "192.169.0.11:/nfs/data     /mnt/nfs/data  nfs     defaults 0 0" >> /etc/fstab
    echo "192.169.0.11:/nfs/logs     /mnt/nfs/logs  nfs     defaults 0 0" >> /etc/fstab
fi
