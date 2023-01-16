# RSA key of size 4096 bits
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "authorized_keys" {
  source          = "./../../../modules/authorized_keys"
  authorized_keys = [tls_private_key.this.public_key_openssh]
}

data "ct_config" "this" {
  content      = module.authorized_keys.butane
  strict       = true
  pretty_print = true

  snippets = var.butane_snippets
}

resource "libvirt_ignition" "this" {
  name    = format("%s-ignition", var.name)
  content = data.ct_config.this.rendered
}

resource "libvirt_volume" "root" {
  name             = format("%s-root", var.name)
  base_volume_name = "coreos"
  lifecycle {
    replace_triggered_by = [
      libvirt_ignition.this
    ]
  }
}

resource "libvirt_domain" "this" {
  name   = var.name
  memory = "4096"
  vcpu   = 4
  cpu {
    mode = "host-passthrough"
  }
  disk {
    volume_id = libvirt_volume.root.id
  }
  dynamic "disk" {
    for_each = var.additional_volume_ids
    content {
      volume_id = disk.value
    }
  }
  network_interface {
    network_name   = var.network_name
    wait_for_lease = true
  }
  coreos_ignition = libvirt_ignition.this.id
}

output "private_key_openssh" {
  value = tls_private_key.this.private_key_openssh
}

output "network_interfaces" {
  value = resource.libvirt_domain.this.network_interface
}
