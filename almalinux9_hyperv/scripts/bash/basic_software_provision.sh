#!/usr/bin/env bash

# Provision basic software. 
echo "Attempting to install basic software ...";
dnf install -yq epel-release
dnf install -yq langpacks-it vim git tree htop net-tools curl wget telnet tmux bash-completion neofetch
localectl set-locale LANG=it_IT.UTF-8 && localectl set-keymap it