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
      version = "~> 4.0"
    }
  }
}

variable "ca" {
  description = "The certificate authorities in PEM format."
  type        = list(string)
}

data "tls_certificate" "this" {
  for_each = { for index, cert in var.ca : index => cert }
  content  = each.value
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    ignition = {
      security = {
        tls = {
          certificate_authorities = [for cert in var.ca : {
            inline = cert
          }]
        }
      }
    }
    storage = {
      files = [for index, cert in var.ca : {
        path = format(
          "/etc/pki/ca-trust/source/anchors/%s.pem",
          regex("^CN=(?P<name>[^,]+),.*", data.tls_certificate.this[index].certificates[0].subject).name
        )
        contents = {
          inline = cert
        }
      }]
    }
  }
}

output "butane" {
  value = yamlencode(local.butane)
}
