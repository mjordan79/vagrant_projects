#!/usr/bin/env bash

USER=$1
PASS=$2
ROOT_PASS=$3
echo "Creating user $USER with password $PASS and adding it to the sudoers list ..."
useradd -m -p $(openssl passwd -1 $PASS) $USER

# If creating the new user went well, we do accessory operations. Otherwise we assume the user already exists and we don't need to do anything.
if [ $? -eq 0 ]
then
    grep -qxF '$USER ALL=(ALL:ALL) ALL' /etc/sudoers || echo "$USER ALL=(ALL:ALL) ALL" >> /etc/sudoers
    touch /home/$USER/.bash_profile
    grep -qxF 'neofetch --ascii_distro Ubuntu' /home/$USER/.bash_profile || echo 'neofetch --ascii_distro Ubuntu' >> /home/$USER/.bash_profile
    groupadd -f docker
    usermod -aG docker $USER

    # Change the root password
    echo "root:$ROOT_PASS" | chpasswd

    # If the /etc/skel/.zshrc file exist, then we want to change the shell from bash to zsh
    FILE=/etc/skel/.zshrc
    if [ -f "$FILE" ]; then
        chsh -s /bin/zsh $USER
    else
        chsh -s /bin/bash $USER
    fi
fi
