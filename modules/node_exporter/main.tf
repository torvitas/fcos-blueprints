locals {
  node_exporter_config = {
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
  value = local.node_exporter_config
}
