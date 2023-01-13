module "pod" {
  source   = "../pod"
  name     = "open-vm-tools"
  manifest = file(format("%s/manifest.yml", path.module))
}

output "butane" {
  value = module.pod.butane
}
