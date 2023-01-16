variable "name" {
  type = string
}

variable "additional_volume_ids" {
  type    = set(string)
  default = []
}

variable "network_name" {
  type    = string
  default = "default"
}

variable "butane_snippets" {
  type = list(string)
}
