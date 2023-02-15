variable "butane" {
  description = "Custom butane configuration"
  type        = string
  default     = null
}

variable "user" {
  description = <<EOT
    Name of the user to be used by default for user dependend modules
    if not specifically configured otherwise in the respective module.
  EOT
  type        = string
}

variable "group" {
  description = <<EOT
    Name of the group to be used by default for user dependend modules
    if not specifically configured otherwise in the respective module.
    The group will default to the user name.
  EOT
  type        = string
  default     = null // defaults to user
}

variable "authorized_keys" {
  description = "List of authorized SSH public keys for the default user."
  type        = list(string)
  default     = null
}

variable "ca" {
  description = "The certificate authorities in PEM format."
  type        = list(string)
  default     = null
}

variable "node_exporter_enabled" {
  description = "Enable node-exporter container."
  type        = bool
  default     = true
}

variable "open_vm_tools_enabled" {
  description = "Enable VMware open-vm-tools to integrate with vSphere."
  type        = bool
  default     = false
}

variable "directory_parents" {
  description = "Ensures a path of directories exists and has the correct permissions."
  type = list(object({
    root  = string
    path  = string
    user  = optional(string)
    group = optional(string)
    mode  = optional(number)
  }))
  default = []
}

variable "pods" {
  description = "List of configuration objects for pod module."
  type = list(object({
    name     = string
    manifest = string
    user     = optional(string)
    group    = optional(string)
  }))
  default = []
}

variable "units" {
  description = "List of configuration objects for user units."
  type = list(object({
    user  = optional(string)
    group = optional(string)
    name  = string
    unit  = string
  }))
}
