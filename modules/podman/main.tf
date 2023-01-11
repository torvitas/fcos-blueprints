variable "device" {
  type = string
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      filesystems = [
        {
          device          = var.device
          path            = "/var/lib/containers"
          format          = "xfs"
          with_mount_unit = true
        }
      ]
    }
    systemd = {
      units = [
        {
          name = "podman-kube@.service"
          dropins = [{
            name     = "10-wait-filesystem.conf"
            contents = file(format("%s/10-wait-filesystem.conf", path.module))
          }]
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
