#!/usr/bin/env bash

USER=$1
PASS=$2
echo "Creating user $USER with password $PASS and adding it to the sudoers list ..."
useradd -p $(openssl passwd -1 $PASS) $USER
echo "$USER  ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "neofetch --ascii_distro AlmaLinux" | tee -a /home/$USER/.bash_profile
usermod -aG docker $USER