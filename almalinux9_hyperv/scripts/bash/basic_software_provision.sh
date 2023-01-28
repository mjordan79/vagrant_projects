#!/usr/bin/env bash

# Provision basic software. 
echo "Attempting to install basic software ...";
dnf install -yq langpacks-it vim git htop net-tools curl wget telnet tmux xorg-x11-xauth bash-completion neofetch && \
    localectl set-locale LANG=it_IT.UTF-8 && localectl set-keymap it
