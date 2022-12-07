locals {
  base_config = {
    variant = var.ct_variant
    version = var.ct_version
  }
}


data "ct_config" "this" {
  content      = yamlencode(local.base_config)
  strict       = true
  pretty_print = false

  snippets = []
}

output "config" {
  description = "CT config object"
  value       = data.ct_config.this
}
