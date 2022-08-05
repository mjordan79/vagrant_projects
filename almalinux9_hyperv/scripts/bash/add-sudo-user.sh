#!/usr/bin/env bash

USER=$1
PASS=$2
echo "Creating user $USER with password $PASS and adding it to the sudoers list ..."
useradd -p $(openssl passwd -1 $PASS) $USER
echo "$USER  ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "neofetch --ascii_distro AlmaLinux" | tee -a /home/$USER/.bash_profile
groupadd -f docker
usermod -aG docker $USER

# If the /etc/skel/.zshrc file exist, then we want to change the shell from bash to zsh
FILE=/etc/skel/.zshrc
if [ -f "$FILE" ]; then
    chsh -s /bin/zsh $USER
fi
