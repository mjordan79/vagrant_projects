#!/usr/bin/env bash
set -euo pipefail

cd ubuntu
packer build -only ubuntu-hyperv-vagrant-22.04.hyperv-iso.ubuntu-server-2204 .
