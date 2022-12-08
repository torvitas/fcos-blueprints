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
  merged = merge(local.base_config, local.node_exporter_config)

}

data "ct_config" "this" {
  content      = yamlencode(local.merged)
  strict       = true
  pretty_print = false
}
