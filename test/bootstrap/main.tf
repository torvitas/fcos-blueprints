terraform {
  required_version = "~> 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "coreos_image" {
  type = string
}

provider "libvirt" {
  uri = var.libvirt_uri
}

resource "libvirt_volume" "coreos" {
  source = var.coreos_image
  name   = "coreos"
}
