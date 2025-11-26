#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Downloading neofetch ..."
curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
chmod +x /usr/bin/neofetch

echo "[INFO] Configuring neofetch ..."
grep -qxF 'neofetch --ascii_distro Ubuntu' $HOME/.bashrc || echo 'neofetch --ascii_distro Ubuntu' >> $HOME/.bashrc
grep -qxF 'neofetch --ascii_distro Ubuntu' /home/vagrant/.bashrc || echo 'neofetch --ascii_distro Ubuntu' >> /home/vagrant/.bashrc

echo "[INFO] Configuring colored output from ls ..."
grep -qxF 'alias ls="ls --color"' $HOME/.bashrc || echo 'alias ls="ls --color"' >> $HOME/.bashrc
grep -qxF 'alias ls="ls --color"' /home/vagrant/.bashrc || echo 'alias ls="ls --color"' >> /home/vagrant/.bashrc

echo "[INFO] Disabling SELinux ..."
setenforce 0 || true
if [ -f /etc/selinux/config ]; then
  sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
fi

echo "[INFO] Disabling AppArmor ..."
systemctl disable apparmor --now

echo "[INFO] Disabling the Uncomplicated Firewall (ufw) ..."
systemctl disable ufw --now
