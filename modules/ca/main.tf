/*
 * # Certificate Authority Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that deploys a CA.
*/

terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

variable "ca" {
  description = "The certificate authority in PEM format."
  type        = string
}

data "tls_certificate" "this" {
  content = var.ca
}

locals {
  name = regex("^CN=(?P<name>[^,]+),.*", data.tls_certificate.this.certificates[0].subject).name
  butane = {
    variant = "fcos"
    version = "1.4.0"
    ignition = {
      security = {
        tls = {
          certificate_authorities = [
            {
              inline = var.ca
            }
          ]
        }
      }
    }
    storage = {
      files = [
        {
          path = format(
            "/etc/pki/ca-trust/source/anchors/%s.pem",
            local.name
          )
          contents = {
            inline = var.ca
          }
        }
      ]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
