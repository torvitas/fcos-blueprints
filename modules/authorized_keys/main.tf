/**
 * # Authorized Keys Ignition Module
 *
 *  [TOC]
 *
 * ## Description
 *
 * Set up authorized_keys file for default user `core`.
 *
 */
variable "authorized_keys" {
  description = "Set of authorized SSH public keys for the default user"
  type        = set(string)
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    passwd = {
      users = [
        {
          name                = "core"
          ssh_authorized_keys = var.authorized_keys
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
