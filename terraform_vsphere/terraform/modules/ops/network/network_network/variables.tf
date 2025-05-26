variable "tenant_id" {
    type = string
    default = null
}

variable "network_name" {}

variable "admin_state_up" {
  type    = bool
  default = true
}

variable "shared_enabled" {
  type    = bool
  default = false
}

variable "external_enabled" {
  type    = bool
  default = false
}

variable "network_type" {
  type    = string
  default = "geneve"
}

variable "physical_network" {
  type    = string
  default = null
}

variable "segmentation_id" {
  type    = number
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}
