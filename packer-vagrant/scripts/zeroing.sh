#!/usr/bin/env bash
set -euo pipefail

echo "Zeroing free space for improving image compression ..."
# Write a file made only by zeroes until the disk is full, then it deletes it.
sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY

# Force disks sync
sync
