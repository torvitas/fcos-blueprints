locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    systemd = {
      units = [
        {
          name     = "open-vm-tools.service"
          enabled  = true
          contents = file("${path.module}/open-vm-tools.service")
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
