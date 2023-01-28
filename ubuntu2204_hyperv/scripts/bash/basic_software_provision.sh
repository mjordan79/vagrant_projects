#!/usr/bin/env bash

# Provision basic software. 
echo "Attempting to install basic software ...";
apt-get update -yq && \
    apt-get install -yq net-tools network-manager policycoreutils policycoreutils-python-utils && \
    localectl set-locale LANG=it_IT.UTF-8 && localectl set-x11-keymap it