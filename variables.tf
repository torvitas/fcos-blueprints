variable "ct_variant" {
  description = "Variant used in CT config YAML"
  type        = string
  default     = "fcos"
}
variable "ct_version" {
  description = "Version used in CT config YAML"
  type        = string
  default     = "1.4.0"
}

variable "passwd_username" {
  description = "Name of the default user"
  type        = string
  default     = "core"
}

variable "passwd_ssh_authorized_keys" {
  description = "List of authorized SSH public keys of the default user"
  type        = list(string)
  default     = [""]
}

// Feature flags
variable "node_exporter_enabled" {
  description = "Enable node-exporter container"
  type        = bool
  default     = true
}

variable "open_vm_tools_enabled" {
  description = "Enable VMware open-vm-tools to integrate with vSphere"
  type        = bool
  default     = false
}
