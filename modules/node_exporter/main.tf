module "pod" {
  source   = "../pod"
  name     = "node-exporter"
  manifest = file(format("%s/manifest.yml", path.module))
}

output "butane" {
  value = module.pod.butane
}
