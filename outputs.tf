output "config" {
  description = "Ignition config object"
  value       = data.ignition_config.this
}

output "rendered" {
  description = "Rendered Ignition config"
  value       = data.ignition_config.this.rendered
}
