
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "fcos" {
  name = "fcos"
  # Maybe adjust to the current downloaded image
  source = "${path.module}/images/fedora-coreos-37.20221106.3.0-qemu.x86_64.qcow2"

}

resource "libvirt_volume" "this" {
  name           = "fcos-ignition-blueprint-demo.qcow2"
  base_volume_id = libvirt_volume.fcos.id

  depends_on = [
    libvirt_ignition.ignition
  ]
  lifecycle {
    replace_triggered_by = [libvirt_ignition.ignition]
  }
}


module "ignition" {
  source                     = "../../"
  passwd_ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXpQIMBqq8WMT+xeG5W2QvQfoIbxQaZ76oU3bPn8Huc "]

}

resource "libvirt_ignition" "ignition" {
  name    = "fcos-ignition-blueprint-demo"
  content = module.ignition.rendered
}

resource "libvirt_domain" "this" {
  name            = "fcos-ignition-blueprint-demo"
  memory          = "2048"
  coreos_ignition = libvirt_ignition.ignition.id
  fw_cfg_name     = "opt/com.coreos/config"

  disk {
    volume_id = libvirt_volume.this.id
  }

  network_interface {
    network_name   = "default"
    hostname       = "fcos-ignition-blueprint-demo"
    wait_for_lease = false
  }

  lifecycle {
    replace_triggered_by = [libvirt_ignition.ignition]
  }
  # Eanble for debug
  # console {
  #   type        = "file"
  #   target_port = "0"
  #   target_type = "serial"
  #   source_path = "/tmp/kvm.log"
  # }
}
