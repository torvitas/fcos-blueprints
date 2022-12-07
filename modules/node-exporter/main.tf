# Node exporter mit defaults als container
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
