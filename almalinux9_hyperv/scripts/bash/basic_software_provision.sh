#!/usr/bin/env bash

# Provision basic software and updates the packages. 
echo "Attempting to install basic software and updates to the distribution ...";
dnf install -yq epel-release && \
dnf update -yq && dnf install -yq langpacks-it vim git htop net-tools curl wget telnet tmux xorg-x11-xauth bash-completion neofetch && \
localectl set-locale LANG=it_IT.UTF-8 && localectl set-keymap it
