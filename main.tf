/**
 * # Terraform Ignition Blueprints
 *
 * [TOC]
 *
 * ## Description
 *
 * Provide a baseline configuration for Ignition/Butane based workloads.
 *
 * ## References
 *
 * * <https://coreos.github.io/butane/config-fcos-v1_4/>
 *
 */

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
  }
  group = coalesce(var.group, var.user)
}

module "authorized_keys" {
  count           = var.authorized_keys != null ? 1 : 0
  source          = "./modules/authorized_keys"
  authorized_keys = var.authorized_keys
  user            = var.user
}

module "ca" {
  count  = var.ca != null ? 1 : 0
  source = "./modules/ca"
  ca     = var.ca
}

module "directory_parents" {
  for_each = { for index, directory in var.directory_parents : index => directory }
  source   = "./modules/directory_parents"
  root     = each.value.root
  path     = each.value.path
  user     = coalesce(each.value.user, var.user)
  group    = coalesce(each.value.group, local.group)
}

module "node_exporter" {
  count  = var.node_exporter_enabled ? 1 : 0
  source = "./modules/node_exporter"
}

module "open_vm_tools" {
  count  = var.open_vm_tools_enabled ? 1 : 0
  source = "./modules/open_vm_tools"
}

module "pod" {
  for_each = { for index, pod in var.pods : index => pod }
  source   = "./modules/pod"
  name     = each.value.name
  manifest = each.value.manifest
  user     = coalesce(each.value.user, var.user)
  group    = coalesce(each.value.group, local.group)
}

module "unit" {
  for_each = { for index, unit in var.units : index => unit }
  source   = "./modules/unit"
  name     = each.value.name
  unit     = each.value.unit
  user     = coalesce(each.value.user, var.user)
  group    = coalesce(each.value.group, local.group)
}

data "ignition_config" "this" {
  content      = yamlencode(local.butane)
  strict       = true
  pretty_print = true

  snippets = concat(
    var.butane != null ? [var.butane] : [],
    [for authorized_keys in module.authorized_keys : authorized_keys.butane],
    [for ca in module.ca : ca.butane],
    [for directory in module.directory_parents : directory.butane],
    [for node_exporter in module.node_exporter : node_exporter.butane],
    [for open_vm_tools in module.open_vm_tools : open_vm_tools.butane],
    [for pod in module.pod : pod.butane],
    [for unit in module.unit : unit.butane]
  )
}
