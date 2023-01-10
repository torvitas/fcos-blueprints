locals {
  # baseline config
  butane = {
    variant = "fcos"
    version = "1.4.0"
    passwd = {
      users = [
        {
          name                = var.passwd_username
          ssh_authorized_keys = var.passwd_ssh_authorized_keys
        }
      ]
    }
    storage = {}
    ignition = {
      security = {
        tls = {
          certificate_authorities = [
            {
              inline = file(format("%s/files/eb_root_ca.crt.pem", path.module))
            }
          ]
        }
      }
    }
  }
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
  content      = yamlencode(local.butane)
  strict       = true
  pretty_print = false
  snippets = concat(
    var.butane != null ? [var.butane] : [],
    [for node_exporter in module.node_exporter : node_exporter.butane],
    [for open_vm_tools in module.open_vm_tools : open_vm_tools.butane]
  )
}
