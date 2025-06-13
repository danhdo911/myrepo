variable "vcd_org" {
  description = "The name of organization"
  type        = string
}

variable "org_network_id" {
  type        = string
}

variable "dhcp_pool_start" {
  type = string
  default = null
}

variable "dhcp_pool_end" {
  type = string
  default = null
}
