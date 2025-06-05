variable "network_id" {
    type = string
}

variable "subnet_name" {
    type = string
}

variable "subnet_cidr" {
    type = string
}

variable "ip_version" {
    description = "IPv4 or IPv6"
    type = number
    validation {
      condition = contains([4, 6], var.ip_version)
      error_message = "ip_version must be one of: 4 or 6"
    }
    default = 4
}

variable "enable_dhcp" {
    type = bool
    default = false
}

# variable "allocation_pool_start" {
#     type = string
#     default = null
# }

# variable "allocation_pool_end" {
#     type = string
#     default = null
# }

variable "allocation_pools" {
    type = list(object({
        allocation_pool_start = optional(string)
        allocation_pool_end = optional(string)
    }))
    default = []
}

variable "dns_nameservers" {
  type = list(string)
  default = null
}