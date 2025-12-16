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
}

source "hyperv-iso" "ubuntu-2204" {
  iso_url            = var.hyperv_iso_url
  iso_checksum       = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  shutdown_command   = "echo 'vagrant' | sudo -S shutdown -P now"
  vm_name            = "ubuntu-22.0.4"
  generation         = 2
  cpus               = 2
  memory             = 4096
  disk_size          = 131072
  enable_secure_boot = false
  switch_name        = "Default Switch"
  boot_wait          = "5s"
  boot_command = [
  "<wait5>", // Aspetta che GRUB compaia
  "e",       // Entra in modalità modifica (Edit) di GRUB
  "<wait2>",
  // Sposta il cursore fino alla fine della riga che inizia con 'linux'
  "<down><down><wait><down><end><wait>",
  "<bs><bs><wait><bs><bs><wait2>",
  // Aggiungi i parametri di autoinstall dopo '...' quiet splash ---'
  " autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ---",
  "<wait5>",
  "<f10>" // F10 per avviare il boot con i parametri modificati
]
  http_content = {
    "/user-data" = templatefile("templates/user-data.template", {
      hostname               = var.hostname
      vagrant_password_hash  = var.vagrant_password_hash
      vagrant_ssh_public_key = local.vagrant_ssh_public_key
    })
    "/meta-data" = <<EOF
instance-id: iid-123456
local-hostname: ${var.hostname}
EOF
  }
  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "30m"
}

build {
  name = "ubuntu-hyperv-to-vagrant"
  sources = [
    "source.hyperv-iso.ubuntu-2204"
  ]

/*

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
      "mkdir -p /home/vagrant/.ssh",
      "curl -L https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys",
      "chown -R vagrant:vagrant /home/vagrant/.ssh",
      "chmod 600 /home/vagrant/.ssh/authorized_keys",
      "echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant",
      "chmod 440 /etc/sudoers.d/vagrant"
    ]
  }

*/

  post-processor "vagrant" {
    output              = "ubuntu-hyperv-vagrant.box"
    keep_input_artifact = false
  }
}

