/*
 * # Open VM Tools Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that deploys the Open VM Tools for for VMWare virtual machines using the
 * pod-module.
 */
module "pod" {
  source   = "../pod"
  name     = "open_vm_tools"
  manifest = file(format("%s/manifest.yml", path.module))
}

output "butane" {
  value = module.pod.butane
}
