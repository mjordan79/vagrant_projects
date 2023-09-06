#!/bin/bash

# Replace this with the active release:
# https://docs.ceph.com/en/latest/releases/#active-releases
CEPH_RELEASE=18.2.0

# They're too lazy to put a binary in the Debian repos, so we need to downlod it from the RHEL repo
curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm

# Make it executable
chmod +x cephadm

./cephadm add-repo --release reef
./cephadm install

# Removing the cephadm command, it has been installed in /usr/sbin
rm -f ./cephadm
cephadm version

