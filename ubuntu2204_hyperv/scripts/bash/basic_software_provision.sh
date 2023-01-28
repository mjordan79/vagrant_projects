#!/usr/bin/env bash

# Provision basic software and updates the packages. 
echo "Attempting to install basic software and updates to the distribution ...";
apt-get update -yq && \
    apt-get upgrade -yq && \
    apt-get install -yq net-tools network-manager policycoreutils policycoreutils-python-utils && \
    localectl set-locale LANG=it_IT.UTF-8 && localectl set-x11-keymap it