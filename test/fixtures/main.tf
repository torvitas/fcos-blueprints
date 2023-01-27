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
  }
}

variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

provider "libvirt" {
  uri = var.libvirt_uri
}

resource "libvirt_volume" "root_data" {
  name = "root-data-blueprints"
  size = 50 * pow(1024, 3) # 50GiB
}

resource "libvirt_volume" "user_data" {
  name = "user-data-blueprints"
  size = 50 * pow(1024, 3) # 50GiB
}

locals {
  butane = {
    variant = "fcos"
    version = "1.4.0"
    ignition = {
      config = {
        merge = [
          {
            inline = module.blueprints.rendered
          }
        ]
      }
    }
    storage = {
      filesystems = [
        {
          device          = "/dev/disk/by-diskseq/2"
          path            = "/var/lib/containers/storage/volumes"
          format          = "xfs"
          with_mount_unit = true
        },
        {
          device          = "/dev/disk/by-diskseq/3"
          path            = "/var/home/core/.local/share/containers/storage/volumes"
          format          = "xfs"
          with_mount_unit = true
        }
      ]
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

resource "tls_private_key" "authorized_key" {
  algorithm = "ED25519"
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

module "blueprints" {
  source                = "./../../"
  user                  = "core"
  authorized_keys       = [tls_private_key.authorized_key.public_key_openssh]
  ca                    = [tls_self_signed_cert.ca.cert_pem]
  node_exporter_enabled = true
  open_vm_tools_enabled = false // wont work on libvirt
  directory_parents = [
    {
      root = "/var/home/core"
      path = "/var/home/core/i/can/has/directory/plx"
    },
    {
      root = "/var/home/core"
      path = "/var/home/core/i/like/trains"
    }
  ]
  pods = [
    {
      name = "nginx"
      manifest = templatefile(format("%s/nginx.manifest.yml", path.module), {
        template_data = jsonencode({
          "default.conf.template" = file(format("%s/nginx.conf.template", path.module))
        })
        tls_data = jsonencode({
          "crt.pem" = tls_locally_signed_cert.localhost.cert_pem
          "key.pem" = tls_private_key.localhost.private_key_pem
        })
      })
    }
  ]
}

module "libvirt_test_vm" {
  source = "./../modules/libvirt"
  name   = "blueprints"

  additional_volume_ids = [
    libvirt_volume.root_data.id,
    libvirt_volume.user_data.id
  ]

  butane_snippets = [
    yamlencode(local.butane)
  ]
}

output "ip_address" {
  value = try(module.libvirt_test_vm.network_interfaces[0].addresses[0], null)
}

output "private_key_openssh" {
  value     = module.libvirt_test_vm.private_key_openssh
  sensitive = true
}

output "ignition" {
  value = module.blueprints.rendered
}
