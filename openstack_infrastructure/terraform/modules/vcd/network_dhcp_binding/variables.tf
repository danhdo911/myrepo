variable "vcd_org" {
  description = "The name of organization"
  type        = string
}

variable "org_dhcp_id" {
  type        = string
}

variable "name" {
  type = string
}

variable "description" {
  type = string
  default = null
}

variable "binding_type" {
  type = string
  default = "IPV4"
}

variable "ip_address" {
  type = string
}

variable "lease_time" {
  type = number
  default = 3600
}

variable "mac_address" {
  type = string
}

variable "dns_servers" {
  type = list(string)
  default = null
}
