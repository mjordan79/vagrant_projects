#!/usr/bin/env bash

echo "Installing Eclipse Temurin JDK 17 ..."

apt install -yq wget apt-transport-https gnupg && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt update -yq && apt install -yq temurin-17-jdk

java -version
