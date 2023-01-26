terraform {
  required_version = "~> 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

provider "libvirt" {
  uri = var.libvirt_uri
}

resource "tls_private_key" "ca" {
  algorithm = "ED25519"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "acse"
    organization = "A Company that Signs Everything"
  }

  validity_period_hours = 12

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

module "ca" {
  source = "./../.."
  ca     = tls_self_signed_cert.ca.cert_pem
}

module "nginx" {
  source = "./../../../pod"
  name   = "nginx"
  manifest = templatefile(format("%s/nginx.manifest.yml", path.module), {
    template_data = jsonencode({
      "default.conf.template" = file(format("%s/nginx.conf.template", path.module))
    })
    tls_data = jsonencode({
      "crt.pem" = tls_locally_signed_cert.localhost.cert_pem
      "key.pem" = tls_private_key.localhost.private_key_pem
    })
  })
  user = "core"
}

resource "tls_private_key" "localhost" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "localhost" {
  private_key_pem = tls_private_key.localhost.private_key_pem
  subject {
    common_name  = "localhost"
    organization = "A Company that Signs Everything"
  }
}

resource "tls_locally_signed_cert" "localhost" {
  cert_request_pem   = tls_cert_request.localhost.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    storage = {
      files = [
        // inject local registries config into vm to be able to use private registry mirrors or similar configuration
        {
          path = "/etc/containers/registries.conf.d/999-local.conf"
          contents = {
            inline = try(file("~/.config/containers/registries.conf"), "")
          }
        }
      ]
    }
  }
}

module "libvirt_test_vm" {
  source = "./../../../../test/modules/libvirt"
  name   = "ca"

  butane_snippets = [
    yamlencode(local.butane),
    module.ca.butane,
    module.nginx.butane
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = module.libvirt_test_vm.private_key_openssh
  sensitive = true
}

output "ca" {
  value = tls_self_signed_cert.ca.cert_pem
}
