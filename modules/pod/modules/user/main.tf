terraform {
  required_version = "~> 1.0"
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
  }
}

variable "user" {
  type    = string
  default = "root"
}

variable "group" {
  type    = string
  default = null
}

variable "name" {
  description = "Name of the pod to be deployed."
  type        = string
}

variable "manifest" {
  description = "The pod manifest."
  type        = string
}

module "default_target_path_parents" {
  source = "../../../directory_parents"
  root = local.home_path
  path = local.default_target_path
  user = var.user
  group = var.group
}

module "manifest_path_parents" {
  source = "../../../directory_parents"
  root = local.home_path
  path = dirname(local.manifest_file)
  user = var.user
  group = var.group
}

module "dropin_path_parents" {
  source = "../../../directory_parents"
  root = local.home_path
  path = dirname(local.service_dropin_file)
  user = var.user
  group = var.group
}

data "ct_config" "directories_parents" {
  content      = yamlencode({
    variant = "fcos"
    version = "1.4.0"
  })
  strict       = true
  pretty_print = true
  snippets = [
    module.dropin_path_parents.butane,
    module.default_target_path_parents.butane,
    module.manifest_path_parents.butane
  ]
}

locals {
  home_path = format("/var/home/%s", var.user)
  systemd_path        = format("%s/.config/systemd/user", local.home_path)
  default_target_path = format("%s/default.target.wants", local.systemd_path)
  manifest_file       = format("%s/.local/etc/kube/%s.yml", local.home_path, var.name)
  service_name = format(
    "podman-kube@%s.service",
    # Apply systemd's path replace algorithm.
    # Note that special characters are not allowed in the pod module. Underscore is not escaped by systemd.
    replace(local.manifest_file, "/", "-")
  )
  service_dropin_file = format("%s/%s.d/10-require-filesystem.conf", local.systemd_path, local.service_name)
  podman_path         = format("%s/.local/share/containers/storage/volumes", local.home_path)
  butane = {
    variant = "fcos"
    version = "1.4.0"
    ignition = {
      config = {
        merge = [
          {
            inline = data.ct_config.directories_parents.rendered
          }
        ]
      }
    }
    storage = {
      links = [
        {
          path = format("%s/%s", local.default_target_path, local.service_name)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          target = "/usr/lib/systemd/system/podman-kube@.service"
        }
      ]
      files = [
        {
          path = local.manifest_file
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          mode = parseint("644", 8)
          contents = {
            inline = var.manifest
          }
        },
        {
          path = local.service_dropin_file
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          mode = parseint("644", 8)
          contents = {
            inline = templatefile(
              format("%s/../../10-require-filesystem.conf.tpl", path.module),
              { podman_path = local.podman_path }
            )
          }
        },
        {
          path = format("/var/lib/systemd/linger/%s", var.user)
          mode = parseint("644", 8)
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
