locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    systemd = {
      units = [
        {
          name     = "open-vm-tools.service"
          enabled  = true
          contents = file(format("%s/open-vm-tools.service", path.module))
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
