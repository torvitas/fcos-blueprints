locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
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

output "butane" {
  value = yamlencode(local.butane)
}
