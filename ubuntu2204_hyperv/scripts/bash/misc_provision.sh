#!/usr/bin/env bash
set -euo pipefail

# User messages are green.
log() {
    echo -e "\e[32m[INFO]\e[0m $*"
}

log "Downloading neofetch ..."
curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o /usr/bin/neofetch
chmod +x /usr/bin/neofetch

log "Configuring neofetch ..."
grep -qxF 'neofetch --ascii_distro Ubuntu' $HOME/.bashrc || echo 'neofetch --ascii_distro Ubuntu' >> $HOME/.bashrc
grep -qxF 'neofetch --ascii_distro Ubuntu' /home/vagrant/.bashrc || echo 'neofetch --ascii_distro Ubuntu' >> /home/vagrant/.bashrc

log "Configuring colored output from ls ..."
grep -qxF 'alias ls="ls --color"' $HOME/.bashrc || echo 'alias ls="ls --color"' >> $HOME/.bashrc
grep -qxF 'alias ls="ls --color"' /home/vagrant/.bashrc || echo 'alias ls="ls --color"' >> /home/vagrant/.bashrc

log "Disabling SELinux ..."
setenforce 0 || true
if [ -f /etc/selinux/config ]; then
  sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
fi

log "Disabling AppArmor ..."
systemctl disable apparmor --now

log "Disabling the Uncomplicated Firewall (ufw) ..."
systemctl disable ufw --now

log "Deleting garbage ..."
rm -f /root/truncate
