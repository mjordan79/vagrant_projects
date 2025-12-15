packer {
    required_plugins {
        hyperv = {
            version = ">= 1.1.5"
            source  = "github.com/hashicorp/hyperv"
        }
        vagrant = {
            version = ">= 1.1.6"
            source  = "github.com/hashicorp/vagrant"
        }
    }
}

variable "hyperv_iso_url" {
    type    = string
    default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

source "hyperv-iso" "ubuntu-22.0.4" {
    iso_url            = var.hyperv_iso_url
    iso_checksum       = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
    shutdown_command  = "echo 'vagrant' | sudo -S shutdown -P now"
    vm_name           = "ubuntu-22.0.4"
    generation = 2
    cpus               = 1
    memory            = 1024
    disk_size         = 131072
    enable_secure_boot = true
    switch_name       = "Default Switch"
    boot_wait        = "5s"
    boot_command = [
        "<esc><wait>",
        "set gfxpayload=1024x768<enter>",
        "linux /casper/vmlinuz quiet autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter>",
        "initrd /casper/initrd<enter>",
        "boot<enter>"
    ]
    communicator      = "ssh"
    ssh_username      = "vagrant"
    ssh_password      = "vagrant"
    ssh_timeout       = "30m"
}

build {
    name = "ubuntu-hyperv-to-vagrant"
    sources = [
        "source.hyperv-iso.ubuntu-22.0.4",
    ]

    provisioner "shell" {
        inline = [
            "echo Installing updates...",
            "sudo apt-get update -y",
            "sudo apt-get upgrade -y",
        ]
    }

    provisioner "shell" {
        inline = [
            "echo Installing Vagrant SSH keys...",
            "mkdir -p /home/packer/.ssh",
            "curl -L https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/packer/.ssh/authorized_keys",
            "chown -R packer:packer /home/packer/.ssh",
            "chmod 600 /home/packer/.ssh/authorized_keys",
        ]
    }

    post-processor "vagrant" {
        format = "hyperv"
        output = "ubuntu-hyperv-vagrant.box"
        keep_input_artifact = false
    }
}

