/*
 * # Open VM Tools Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that deploys the Open VM Tools for for VMWare virtual machines using the
 * pod-module.
 * The pod definition is roughly based on this blog post:
 * <https://developers.redhat.com/blog/2017/03/23/containerizing-open-vm-tools-part-1-the-dockerfile-and-constructing-a-systemd-unit-file>
 */
module "pod" {
  source   = "../pod"
  name     = "open-vm-tools"
  manifest = file(format("%s/manifest.yml", path.module))
}

output "butane" {
  value = module.pod.butane
}
