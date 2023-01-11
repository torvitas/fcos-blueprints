variable "name" {
  type = string
}

variable "manifest" {
  type = string
}

locals {
  pod_path = format("/usr/local/etc/kube/%s.yml", var.name)
  butane = {
    variant = "fcos"
    version = "1.4.0"
    systemd = {
      units = [
        {
          name    = format("podman-kube@%s.service", replace(local.pod_path, "/", "-"))
          enabled = true
        }
      ]
    }
    storage = {
      files = [
        {
          path = local.pod_path
          mode = parseint("644", 8)
          contents = {
            inline = var.manifest
          }
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
