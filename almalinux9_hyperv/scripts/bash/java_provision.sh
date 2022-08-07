#!/usr/bin/env bash

echo "Installing Eclipse Temurin JDK 17 ..."

# Adding the Adoptium repo for Eclipse Temurin project 
cat <<EOF > /etc/yum.repos.d/adoptium.repo
[Adoptium]
name=Adoptium
baseurl=https://packages.adoptium.net/artifactory/rpm/rhel/9/x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
EOF

dnf update -yq && dnf install -yq temurin-17-jdk
