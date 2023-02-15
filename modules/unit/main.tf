/*
 * # User Unit Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that deploys a user unit.
*/

variable "user" {
  description = "The user that should run the unit."
  type        = string
  validation {
    condition     = !can(regex("^root$", var.user))
    error_message = "This module is meant to be used for non-root-user units."
  }
}

variable "group" {
  description = "The group that should run the unit."
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the unit to be deployed."
  type        = string
}

variable "unit" {
  description = "Unit file content."
  type        = string
}

locals {
  group               = coalesce(var.group, var.user)
  home_path           = format("/var/home/%s", var.user)
  systemd_path        = format("%s/.config/systemd/user", local.home_path)
  default_target_path = format("%s/default.target.wants", local.systemd_path)
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      files = [
        {
          path = format("%s/%s", local.systemd_path, var.name)
          mode = parseint("644", 8)
          user = {
            name = var.user
          }
          group = {
            name = local.group
          }
          contents = {
            inline = var.unit
          }
        }
      ]
      links = [
        {
          path   = format("%s/%s", local.default_target_path, var.name)
          target = format("%s/%s", local.systemd_path, var.name)
          user = {
            name = var.user
          }
          group = {
            name = local.group
          }
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
