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

module "directory_parents" {
  source = "./../.."
  root   = "/var/home/core"
  path   = "/var/home/core/a/company/that/makes/folders"
  user   = "core"
  mode   = parseint("755", 8)
}

module "libvirt_test_vm" {
  source = "./../../../../test/modules/libvirt"
  name   = "directory_parents"

  butane_snippets = [
    module.directory_parents.butane
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = module.libvirt_test_vm.private_key_openssh
  sensitive = true
}
