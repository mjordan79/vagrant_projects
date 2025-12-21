#!/usr/bin/env bash

# Disable the daemon to remove the symlihk.
sudo systemctl disable hv-kvp-daemon.service

# Override the default unit file with a version that won't hang during boot ups.

sudo tee /etc/systemd/system/multi-user.target.wants/hv-kvp-daemon.service > /dev/null <<'EOF'
[Unit]
Description=Hyper-V KVP Protocol Daemon
ConditionVirtualization=microsoft
ConditionPathExists=/dev/vmbus/hv_kvp
DefaultDependencies=no
BindsTo=sys-devices-virtual-misc-vmbus\x21hv_kvp.device
After=systemd-remount-fs.service
Before=shutdown.target cloud-init-local.service walinuxagent.service
Conflicts=shutdown.target
RequiresMountsFor=/var/lib/hyperv

[Service]
ExecStart=/usr/sbin/hv_kvp_daemon -n

[Install]
WantedBy=multi-user.target

EOF
