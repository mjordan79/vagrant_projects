/**
 * Variables specific for Ubuntu 22.04
 */
variable "hyperv_iso_url_2204" {
  type    = string
  default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "box_name_2204" {
  type    = string
  default = "ubuntu-server-2204-lts.box"
}

/**
 * Variables specific for Ubuntu 24.04
 */
variable "hyperv_iso_url_2404" {
  type = string
  default = "https://releases.ubuntu.com/24.04/ubuntu-24.04.3-live-server-amd64.iso"
}

variable "box_name_2404" {
  type    = string
  default = "ubuntu-server-2404-lts.box"
}

/**
 * Variables valid for all builders.
 */
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
