locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    systemd = {
      units = [
        {
          name     = "node-exporter.service"
          enabled  = true
          contents = file(format("%s/node-exporter.service", path.module))
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
