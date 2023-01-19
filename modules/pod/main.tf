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
  validation {
    # systemd will escape special characters in an ugly way, so we prevent them
    # In particular, "-" will become "\x2d"
    condition     = can(regex("^[0-9A-Za-z_]+$", var.name))
    error_message = "The name of the pod must match ^[0-9A-Za-z_]+$"
  }
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
  is_root = var.user == "root"
  group   = var.group != null ? var.group : var.user
}

module "root" {
  source   = "./modules/root"
  count    = local.is_root ? 1 : 0
  name     = var.name
  manifest = var.manifest
}

module "user" {
  source   = "./modules/user"
  count    = local.is_root ? 0 : 1
  name     = var.name
  manifest = var.manifest
  user     = var.user
  group    = local.group
}

output "butane" {
  value = local.is_root ? module.root[0].butane : module.user[0].butane
}
