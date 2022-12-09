locals {
  config = {
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

output "config" {
  value = local.config
}
