variable "hyperv_iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "hostname" {
  type    = string
  default = "ubuntu"
}

// SHA-512 hash
variable "vagrant_password_hash" {
  type    = string
  default = "$6$tEk1141N8WO7HAIF$HDYDDTtR/bOgAe6t0jdesH/BZB/IOLbEzYqfvKCsZxxsIALSsgGqrZXTSlXtqayJ.HX13rBRYxBzqWEV48Hpt0"
}

variable "shutdown_timeout" {
  type    = string
  default = "20s"
}

variable "box_name" {
  type    = string
  default = "ubuntu-server-2204-lts.box"
}
