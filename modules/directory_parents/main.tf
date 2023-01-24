variable "root" {
  type = string
}

variable "path" {
  type = string
}

variable "user" {
  type    = string
  default = "root"
}

variable "group" {
  type    = string
  default = null
}

variable "mode" {
  type = number
  default = 493 // same as 'parseint("755", 8)', but it is not possible to call functions here
}

locals {
  group   = var.group != null ? var.group : var.user
  new_path_segments = regexall("/[^/]+", trimprefix(var.path, var.root))
  directories = [ for index, _ in local.new_path_segments : {
    path = format("%s%s", var.root, join("", slice(local.new_path_segments, 0, index + 1)))
    user = {
      name = var.user
    }
    group = {
      name = local.group
    }
    mode = var.mode
  }]
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      directories = local.directories
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
