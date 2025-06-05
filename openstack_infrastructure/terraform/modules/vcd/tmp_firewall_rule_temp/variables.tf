# variable "edge_gateway_id" {
#   description = "The ID of the NSX-T edge gateway"
#   type        = string
# }

# variable "firewall_rule_name" {
#   description = "Explanatory name for the firewall rule (uniqueness not enforced)"
#   type        = string
# }

# variable "direction" {
#   description = "Traffic direction: IN, OUT, or IN_OUT"
#   type        = string
#   validation {
#     condition     = contains(["IN", "OUT", "IN_OUT"], var.direction)
#     error_message = "Direction must be one of: IN, OUT, IN_OUT."
#   }
# }

# variable "ip_protocol" {
#   description = "IP protocol: IPV4, IPV6, or IPV4_IPV6"
#   type        = string
#   validation {
#     condition     = contains(["IPV4", "IPV6", "IPV4_IPV6"], var.ip_protocol)
#     error_message = "IP protocol must be one of: IPV4, IPV6, IPV4_IPV6."
#   }
# }

# variable "action" {
#   description = "Action to take: ALLOW, DROP, or REJECT"
#   type        = string
#   validation {
#     condition     = contains(["ALLOW", "DROP", "REJECT"], var.action)
#     error_message = "Action must be one of: ALLOW, DROP, REJECT."
#   }
# }

# variable "enabled" {
#   description = "Whether the rule is enabled"
#   type        = bool
#   default     = true
# }

# variable "logging" {
#   description = "Whether logging is enabled for the rule"
#   type        = bool
#   default     = false
# }

# variable "source_ids" {
#   description = "Set of source Firewall Group IDs (IP Sets or Security Groups); empty = any"
#   type        = set(string)
#   default     = []
# }

# variable "destination_ids" {
#   description = "Set of destination Firewall Group IDs (IP Sets or Security Groups); empty = any"
#   type        = set(string)
#   default     = []
# }

# variable "app_port_profile_ids" {
#   description = "Set of Application Port Profile IDs; empty = any"
#   type        = set(string)
#   default     = []
# }

# variable "rules" {
#   description = "List of firewall rules"
#   type = list(object({
#     name                 = string
#     direction            = string
#     ip_protocol          = string
#     action               = string
#     enabled              = optional(bool, true)
#     logging              = optional(bool, false)
#     source_ids           = optional(set(string), [])
#     destination_ids      = optional(set(string), [])
#     app_port_profile_ids = optional(set(string), [])
#   }))
# }

variable "vdc_org_name" {}

variable "vdc_group_name" {}

variable "vdc_edge_name" {}

variable "app_port_profiles" {
  description = "Map of app port profiles with their corresponding scopes"
  type        = map(string)
  default     = {}
}

variable "ip_set_names" {
  type    = list(string)
  default = []
}

variable "dynamic_security_group_names" {
  type    = list(string)
  default = []
}

variable "security_group_names" {
  type    = list(string)
  default = []
}

variable "rules" {
  description = "List of firewall rules"
  type = list(object({
    name                 = string
    direction            = string
    ip_protocol          = string
    action               = string
    enabled              = optional(bool, true)
    logging              = optional(bool, false)
    source_ids           = optional(set(string), [])
    destination_ids      = optional(set(string), [])
    app_port_profile_ids = optional(set(string), [])
  }))

  validation {
    condition = alltrue([
      for r in var.rules : contains(["IN", "OUT", "IN_OUT"], r.direction)
    ])
    error_message = "Each rule must have 'direction' set to IN, OUT, or IN_OUT."
  }

  validation {
    condition = alltrue([
      for r in var.rules : contains(["IPV4", "IPV6", "IPV4_IPV6"], r.ip_protocol)
    ])
    error_message = "Each rule must have 'ip_protocol' set to IPV4, IPV6, or IPV4_IPV6."
  }

  validation {
    condition = alltrue([
      for r in var.rules : contains(["ALLOW", "DROP", "REJECT"], r.action)
    ])
    error_message = "Each rule must have 'action' set to ALLOW, DROP, or REJECT."
  }
}


