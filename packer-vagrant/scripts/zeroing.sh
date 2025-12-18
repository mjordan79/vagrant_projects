#!/usr/bin/env bash
set -euo pipefail

echo "Azzeramento dello spazio libero (per migliorare la compressione)..."
# Scrive un file di soli zero finché il disco è pieno, poi lo cancella
sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY

# Forza il sync dei dischi
sync
