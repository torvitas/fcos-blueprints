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
  validation {
    condition     = can(yamldecode(var.manifest))
    error_message = "The manifest must be valid yaml."
  }
}

locals {
  systemd_path        = format("/var/home/%s/.config/systemd/user", var.user)
  default_target_path = format("%s/default.target.wants", local.systemd_path)
  manifest_path       = format("/var/home/%s/.local/etc/kube/%s.yml", var.user, var.name)
  service_name = format(
    "podman-kube@%s.service",
    # Apply systemd's path replace algorithm.
    # Note that special characters are not allowed in the pod module. Underscore is not escaped by systemd.
    replace(local.manifest_path, "/", "-")
  )
  service_dropin_path = format("%s/%s.d/10-require-filesystem.conf", local.systemd_path, local.service_name)
  podman_path         = format("/var/home/%s/.local/share/containers/storage/volumes", var.user)
  butane = {
    variant = "fcos"
    version = "1.4.0"
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
      directories = [
        # We want to make sure that each folder in the path (outside of `/var/home/`) to the manifest is owned by the user.
        # If we just use the final path, the folders in between are owned by `root:root`.
        # E. g. if we just make sure `/var/home/$user/.local/etc/kube` exists,
        # the `.local` folder is owned by `root:root`, not by the user.
        {
          path = format("/var/home/%s", var.user)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
        },
        {
          path = format("/var/home/%s/.local", var.user)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
        },
        {
          path = format("/var/home/%s/.local/etc", var.user)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
        },
        {
          path = format("/var/home/%s/.local/etc/kube", var.user)
          user = {
            name = var.user
          }
          group = {
            name = var.group
          }
        }
      ]
      files = [
        {
          path = local.manifest_path
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
          path = local.service_dropin_path
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
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
