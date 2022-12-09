# KVM Example

Deploy the Ignition blueprints to a local KVM stack. This is handy for local testing without cloud resources.

## Usage

Qemu requires a FCOS image to be present on the host. Download it via the `prepare.sh`.
Maybe the name of the image has changed. Adjust the image name in Terraform accordingly.

## Caveats

If you need to redeploy the VM it's not enough to destroy the VM resource.
You also have to destroy the volume of the VM. Otherwise only the libvirt domain will be recreates,
but the os disk is still in place.
