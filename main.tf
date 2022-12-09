locals {
  # baseline config
  base_config = {
    variant = var.ct_variant
    version = var.ct_version
    passwd = {
      users = [
        {
          name                = var.passwd_username
          ssh_authorized_keys = var.passwd_ssh_authorized_keys
        }
      ]
    }
  }

  # Merge all parts into one big config
  merged = merge(
    local.base_config,
    var.node_exporter_enabled ? module.node_exporter[0].config : {},
    var.open_vm_tools_enabled ? module.open_vm_tools[0].config : {}
  )
}

module "node_exporter" {
  count  = var.node_exporter_enabled ? 1 : 0
  source = "./modules/node_exporter"
}
module "open_vm_tools" {
  count  = var.open_vm_tools_enabled ? 1 : 0
  source = "./modules/open_vm_tools"
}

data "ct_config" "this" {
  content      = yamlencode(local.merged)
  strict       = true
  pretty_print = false
}
