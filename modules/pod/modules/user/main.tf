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

// Ensure all the parent directories actually exist and belong to the user
module "default_target_path_parents" {
  source = "../../../directory_parents"
  root   = local.home_path
  path   = local.default_target_path
  user   = var.user
  group  = var.group
}
module "network_online_target_path_parents" {
  source = "../../../directory_parents"
  root   = local.home_path
  path   = local.network_online_target_path
  user   = var.user
  group  = var.group
}
module "manifest_path_parents" {
  source = "../../../directory_parents"
  root   = local.home_path
  path   = dirname(local.manifest_file)
  user   = var.user
  group  = var.group
}
module "dropin_path_parents" {
  source = "../../../directory_parents"
  root   = local.home_path
  path   = dirname(local.service_dropin_file)
  user   = var.user
  group  = var.group
}
// Render butane for parent directories to be able to inject it into the current butane configuration
data "ct_config" "directories_parents" {
  content = yamlencode({
    variant = "fcos"
    version = "1.4.0"
  })
  strict       = true
  pretty_print = true
  snippets = [
    module.dropin_path_parents.butane,
    module.network_online_target_path_parents.butane,
    module.default_target_path_parents.butane,
    module.manifest_path_parents.butane
  ]
}

locals {
  home_path                  = format("/var/home/%s", var.user)
  systemd_path               = format("%s/.config/systemd/user", local.home_path)
  default_target_path        = format("%s/default.target.wants", local.systemd_path)
  network_online_target_path = format("%s/network-online.target.wants", local.systemd_path)
  manifest_file              = format("%s/.local/etc/kube/%s.yml", local.home_path, var.name)
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
        // Enable service by creating link in default target
        {
          path = format("%s/%s", local.default_target_path, local.service_name)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          target = "/usr/lib/systemd/system/podman-kube@.service"
        },
        // Make network-online target available in user
        {
          path = format("%s/network-online.target", local.systemd_path)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          target = "/usr/lib/systemd/system/network-online.target"
        },
        // Make NetworkManager-wait-online service available in user
        {
          path = format("%s/NetworkManager-wait-online.service", local.systemd_path)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          target = "/usr/lib/systemd/system/NetworkManager-wait-online.service"
        },
        // Enable NetworkManager-wait-online service in user
        {
          path = format("%s/NetworkManager-wait-online.service", local.network_online_target_path)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
          target = format("%s/NetworkManager-wait-online.service", local.systemd_path)
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
        // We set up lingering for the systemd user level instance so that it gets started directly on boot
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
