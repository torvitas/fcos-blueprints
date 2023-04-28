terraform {
  required_version = "~> 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    ignition = {
      source  = "e-breuninger/ignition"
      version = "1.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

provider "libvirt" {
  uri = var.libvirt_uri
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

module "authorized_keys" {
  source          = "./../.."
  authorized_keys = [tls_private_key.this.public_key_openssh]
}

module "libvirt_test_vm" {
  source = "./../../../../test/modules/libvirt"
  name   = "authorized_keys"

  butane_snippets = [
    module.authorized_keys.butane
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = tls_private_key.this.private_key_openssh
  sensitive = true
}
