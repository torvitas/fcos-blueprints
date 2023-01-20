terraform {
  required_version = "~> 1.0"

  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
  }
}

module "open_vm_tools" {
  source = "../.."
}

data "ct_config" "this" {
  content      = module.open_vm_tools.butane
  strict       = true
  pretty_print = true
}

output "ignition" {
  value = data.ct_config.this.rendered
}
