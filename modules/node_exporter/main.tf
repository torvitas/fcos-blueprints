/*
 * # Node Exporter Ignition Module
 *
 * [TOC]
 *
 * ## Description
 *
 * This module returns a butane config that deploys the Node Exporter for for Prometheus using the pod-module.
*/
module "pod" {
  source   = "../pod"
  name     = "node_exporter"
  manifest = file(format("%s/manifest.yml", path.module))
}

output "butane" {
  value = module.pod.butane
}
