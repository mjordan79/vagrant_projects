/**
 * Builds an Ubuntu Server 22.04 LTS Hyper-V image specifically tailored for Vagrant.
 * Copyright(C) 2025 Renato Perini.
 * This work is licensed under the Creative Commons Attribution 4.0 International License.
 */
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

locals {
  vagrant_ssh_public_key = chomp(file("keys/vagrant.pub"))
  date_version           = formatdate("YYYYMMDD", timestamp())
  box_version            = "1.0.${local.date_version}"
}

source "hyperv-iso" "ubuntu-server-2204" {
  iso_url                          = var.hyperv_iso_url
  iso_checksum                     = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  vm_name                          = "ubuntu-server-22.04"
  generation                       = 2
  cpus                             = 8
  memory                           = 2048
  disk_size                        = 131072
  enable_secure_boot               = true
  secure_boot_template             = "MicrosoftUEFICertificateAuthority"
  switch_name                      = "Default Switch"
  enable_virtualization_extensions = true
  boot_wait                        = "3s"
  disk_block_size                  = 1
  boot_command = [
    "<wait2>", // Wait that GRUB menu appears
    "e",       // Enter GRUB edit mode
    "<wait>",
    "<down><down><wait><down><end><wait>",
    "<bs><bs><wait><bs><bs><wait>",
    // autoinstall configured with an http server for getting user-data and meta-data
    "autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ---",
    "<wait2>",
    "<f10>" // Boot the system
  ]
  http_content = {
    "/user-data" = templatefile("templates/user-data.template", {
      hostname               = var.hostname
      vagrant_password_hash  = var.vagrant_password_hash
      vagrant_ssh_public_key = local.vagrant_ssh_public_key
    })
    "/meta-data" = <<-EOF
      instance-id: iid-123456
      local-hostname: ${var.hostname}
    EOF
  }
  communicator     = "ssh"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "30m"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  shutdown_timeout = var.shutdown_timeout
}

build {
  name = "ubuntu-hyperv-vagrant"
  sources = [
    "source.hyperv-iso.ubuntu-server-2204"
  ]

  provisioner "shell" {
    script = "scripts/zeroing.sh"
  }

  post-processor "vagrant" {
    architecture         = "amd64"
    compression_level    = 9
    keep_input_artifact  = false
    output               = var.box_name
    vagrantfile_template = "templates/Vagrantfile.hyperv.template"
  }
}
