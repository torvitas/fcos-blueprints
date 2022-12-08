output "config" {
  description = "War CT config object"
  value       = data.ct_config.this
}

output "rendered" {
  description = "Rendered ignition config"
  value       = data.ct_config.this.rendered
}
