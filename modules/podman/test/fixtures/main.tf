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

module "podman" {
  source = "./../../"
  device = "/dev/disk/by-diskseq/2"
}

resource "libvirt_volume" "data" {
  name = "data"
  size = 50 * pow(1024, 3) # 50GiB
}

module "libvirt_test_vm" {
  source                = "./../../../../test/modules/libvirt"
  name                  = "podman"
  additional_volume_ids = [libvirt_volume.data.id]
  butane_snippets       = [module.podman.butane]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}
