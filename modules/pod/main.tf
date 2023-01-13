/*
 * # Pod Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that deploys and enables a pod as a systemd service.
 *
 * ## Features
 *
 * Currently, the following things are implemented:
 *
 * - deploy pod manifest to /usr/local/etc/kube/<pod-name>.yml
 * - enable pod systemd service via podman-kube service template
*/
variable "name" {
  type = string
}

variable "manifest" {
  type = string
}

locals {
  pod_path = format("/usr/local/etc/kube/%s.yml", var.name)
  # First replace dashes with systemd escape sequence, then replace slashes with dashes
  systemd_path_escaped = replace(replace(local.pod_path, "-", "\\x2d"), "/", "-")
  butane = {
    variant = "fcos"
    version = "1.4.0"
    systemd = {
      units = [
        {
          name    = format("podman-kube@%s.service", local.systemd_path_escaped)
          enabled = true
        }
      ]
    }
    storage = {
      files = [
        {
          path = local.pod_path
          mode = parseint("644", 8)
          contents = {
            inline = var.manifest
          }
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
