/*
 * # Podman Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that configure podman.
 *
 * ## Features
 *
 * Currently, the following things are implemented:
 *
 * - mount a block device to /var/lib/containers
 * - add a systemd drop-in for the podman-kube service template, which is provided by the podman package by default
*/
variable "device" {
  type        = string
  description = ""
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      filesystems = [
        {
          device          = var.device
          path            = "/var/lib/containers"
          format          = "xfs"
          with_mount_unit = true
        }
      ]
    }
    systemd = {
      units = [
        {
          name = "podman-kube@.service"
          dropins = [{
            name     = "10-wait-filesystem.conf"
            contents = file(format("%s/10-wait-filesystem.conf", path.module))
          }]
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
