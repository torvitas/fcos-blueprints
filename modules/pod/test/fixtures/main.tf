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

resource "libvirt_volume" "root_data" {
  name = "root-data"
  size = 50 * pow(1024, 3) # 50GiB
}

resource "libvirt_volume" "user_data" {
  name = "user-data"
  size = 50 * pow(1024, 3) # 50GiB
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      filesystems = [
        {
          device          = "/dev/disk/by-diskseq/2"
          path            = "/var/lib/containers"
          format          = "xfs"
          with_mount_unit = true
        },
        {
          device          = "/dev/disk/by-diskseq/3"
          path            = "/var/home"
          format          = "xfs"
          with_mount_unit = true
        }
      ]
    }
  }
}

module "pod_root_0" {
  source   = "./../../"
  name     = "nginx_0"
  manifest = file(format("%s/nginx-root-0.yml", path.module))
}

module "pod_root_1" {
  source   = "./../../"
  name     = "nginx_1"
  manifest = file(format("%s/nginx-root-1.yml", path.module))
}

module "pod_core_0" {
  source   = "./../../"
  name     = "nginx_0"
  manifest = file(format("%s/nginx-core-0.yml", path.module))
  user     = "core"
}

module "pod_core_1" {
  source   = "./../../"
  name     = "nginx_1"
  manifest = file(format("%s/nginx-core-1.yml", path.module))
  user     = "core"
}

module "libvirt_test_vm" {
  source = "./../../../../test/modules/libvirt"
  name   = "pod"

  additional_volume_ids = [
    libvirt_volume.root_data.id,
    libvirt_volume.user_data.id
  ]

  butane_snippets = [
    yamlencode(local.butane),
    module.pod_root_0.butane,
    module.pod_root_1.butane,
    module.pod_core_0.butane,
    module.pod_core_1.butane
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = module.libvirt_test_vm.private_key_openssh
  sensitive = true
}
