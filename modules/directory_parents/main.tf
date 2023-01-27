/*
 * # Directory Parents Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that ensures a path of directories exists and has the correct permissions.
*/

variable "root" {
  description = "Root path that is assumed to already exist."
  type        = string
  validation {
    condition     = !can(regex("/$", trimsuffix(var.root, "/")))
    error_message = "The root path must not have multiple trailing slashes."
  }
}

variable "path" {
  description = "Absolute path that should exist."
  type        = string
  validation {
    condition     = !can(regex("/$", trimsuffix(var.path, "/")))
    error_message = "The path must not have multiple trailing slashes."
  }
}

variable "user" {
  description = "The user that should be the owner of the path."
  type        = string
}

variable "group" {
  description = "The group that should be assigned to the path."
  type        = string
  default     = null
}

variable "mode" {
  description = "The permissions that should be applied to the path."
  type        = number
  default     = 493 // same as 'parseint("755", 8)', but it is not possible to call functions here
}

locals {
  group             = coalesce(var.group, var.user)
  root              = trimsuffix(var.root, "/")
  path              = trimsuffix(var.path, "/")
  new_path_segments = regexall("/[^/]+", trimprefix(local.path, local.root))
  directories = [for index, _ in local.new_path_segments : {
    path = format("%s%s", local.root, join("", slice(local.new_path_segments, 0, index + 1)))
    user = {
      name = var.user
    }
    group = {
      name = local.group
    }
    mode = var.mode
  }]
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      directories = local.directories
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
