#!/usr/bin/env bash

# Provision basic software. 
echo "Attempting to install basic software ...";
apt update -yq && \
    apt install -yq net-tools network-manager policycoreutils policycoreutils-python-utils && \
    localectl set-locale LANG=it_IT.UTF-8 && localectl set-x11-keymap it && snap refresh