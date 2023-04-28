terraform {
  required_version = "~> 1.0"

  required_providers {
    ignition = {
      source  = "e-breuninger/ignition"
      version = "1.0.0"
    }
  }
}

module "open_vm_tools" {
  source = "../.."
}

data "ignition_config" "this" {
  content      = module.open_vm_tools.butane
  strict       = true
  pretty_print = true
}

output "ignition" {
  value = data.ignition_config.this.rendered
}
