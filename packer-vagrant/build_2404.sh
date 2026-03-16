#!/usr/bin/env bash
set -euo pipefail

cd ubuntu
# Build the image ...
packer build -only ubuntu-hyperv-vagrant-24.04.hyperv-iso.ubuntu-server-2404 .
# and import it into vagrant.
vagrant box add --name digitalnucleus/ubuntu-server-24.04 --provider hyperv ./ubuntu-server-2404-lts.box
