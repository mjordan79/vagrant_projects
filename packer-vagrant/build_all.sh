#!/usr/bin/env bash
set -euo pipefail

for dir in ubuntu/*; do
  (
    cd "$dir"
    packer build .
  ) &
done

wait
