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
  }
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

provider "libvirt" {
  uri = var.libvirt_uri
}

module "unit_0" {
  source = "./../.."
  name   = "unit_0.service"
  unit   = file(format("%s/unit-0.service", path.module))
  user   = "core"
}

module "libvirt_test_vm" {
  source = "./../../../../test/modules/libvirt"
  name   = "unit"

  butane_snippets = [
    module.unit_0.butane,
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = module.libvirt_test_vm.private_key_openssh
  sensitive = true
}
