variable "hyperv_iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "hostname" {
  type    = string
  default = "ubuntu"
}

variable "vagrant_password_hash" {
  type    = string
  default = "$6$tEk1141N8WO7HAIF$HDYDDTtR/bOgAe6t0jdesH/BZB/IOLbEzYqfvKCsZxxsIALSsgGqrZXTSlXtqayJ.HX13rBRYxBzqWEV48Hpt0"
}
