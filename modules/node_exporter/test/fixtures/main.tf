terraform {
  required_version = "~> 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
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

module "node_exporter" {
  source = "./../.."
}

module "libvirt_test_vm" {
  source = "./../../../../test/modules/libvirt"
  name   = "node_exporter"

  butane_snippets = [
    module.node_exporter.butane
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = module.libvirt_test_vm.private_key_openssh
  sensitive = true
}
