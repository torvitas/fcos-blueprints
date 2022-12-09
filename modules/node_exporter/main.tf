locals {
  config = {
    systemd = {
      units = [
        {
          name     = "node-exporter.service"
          enabled  = true
          contents = file("${path.module}/node-exporter.service")
        }
      ]
    }
  }
}

output "config" {
  value = local.config
}
