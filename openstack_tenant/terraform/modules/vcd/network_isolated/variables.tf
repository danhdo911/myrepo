variable "network_name" {
  type = string
}

variable "gateway" {
  type = string
}

variable "prefix_length" {
  type = number
}

variable "dns1" {
  type    = string
  default = null
}

variable "dns2" {
  type    = string
  default = null
}

variable "ip_pool_start" {
  type = string
  default = null
}

variable "ip_pool_end" {
  type = string
  default = null
}

variable "enable_static_ip_pool" {
  type    = bool
  default = false
}