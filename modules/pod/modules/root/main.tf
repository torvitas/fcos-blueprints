variable "name" {
  description = "Name of the pod to be deployed."
  type        = string
}

variable "manifest" {
  description = "The pod manifest."
  type        = string
}

locals {
  manifest_path = format("/usr/local/etc/kube/%s.yml", var.name)
  service_name = format(
    "podman-kube@%s.service",
    # Apply systemd's path replace algorithm.
    # Note that special characters are not allowed in the pod module. Underscore is not escaped by systemd.
    replace(local.manifest_path, "/", "-")
  )
  podman_path = "/var/lib/containers/storage/volumes"
  butane = {
    variant = "fcos"
    version = "1.4.0"
    systemd = {
      units = [
        {
          name    = local.service_name
          enabled = true
          dropins = [{
            name = "10-require-filesystem.conf"
            contents = templatefile(
              format("%s/../../10-require-filesystem.conf.tpl", path.module),
              { podman_path = local.podman_path }
            )
          }]
        }
      ]
    }
    storage = {
      files = [
        {
          path = local.manifest_path
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
