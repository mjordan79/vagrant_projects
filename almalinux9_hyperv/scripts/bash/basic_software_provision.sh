#!/usr/bin/env bash

# Provision basic software and updates the packages. 
echo "Attempting to install basic software and updates to the distribution ...";
dnf install -yq epel-release && \
dnf update -yq && dnf install -yq vim git htop net-tools curl telnet tmux xorg-x11-xauth bash-completion neofetch
