#!/usr/bin/env bash
set -euo pipefail

cd ubuntu
# Build the image ...
packer build -only ubuntu-hyperv-vagrant-22.04.hyperv-iso.ubuntu-server-2204 .
# and import it into vagrant.
vagrant box add --name digitalnucleus/ubuntu-server-22.04 --provider hyperv ./ubuntu-server-2204-lts.box
