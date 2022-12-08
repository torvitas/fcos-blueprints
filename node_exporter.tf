locals {
  node_exporter_config = var.node_exporter_enabled ? {
    systemd = {
      units = [
        {
          name     = "node-exporter.service"
          enabled  = true
          contents = file("${path.module}/systemd/node-exporter.service")
        }
      ]
    }
  } : {}
}
