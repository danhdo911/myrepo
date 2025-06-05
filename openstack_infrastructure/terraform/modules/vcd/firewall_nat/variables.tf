variable "vcd_org" {
  description = "The name of the vCD organization"
  type        = string
}

variable "edge_gateway_id" {
  description = "The ID of the NSX-T edge gateway"
  type        = string
}

variable "rule_name" {
  description = "The name of the NAT rule"
  type        = string
}

variable "rule_type" {
  description = "Type of NAT rule (e.g., DNAT, SNAT, REFLEXIVE)"
  type        = string
  validation {
    condition     = contains(["DNAT", "SNAT", "REFLEXIVE"], var.rule_type)
    error_message = "rule_type must be one of: DNAT, SNAT, REFLEXIVE"
  }
}

variable "description" {
  description = "The description of the NAT rule"
  type        = string
  default     = ""
}

variable "external_address" {
  description = "The external IP address used by the NAT rule"
  type        = string
}

variable "internal_address" {
  description = "The internal IP address for the NAT rule"
  type        = string
}

variable "app_port_profile_id" {
  description = "Application port profile IDs"
  type        = string
  default     = null
}

variable "dnat_external_port" {
  description = "The external port for DNAT rules"
  type        = string
  default     = null
}

variable "snat_destination_address" {
  description = "The destination address for SNAT rules"
  type        = string
  default     = null
}

variable "enabled_logging" {
  description = "Whether to enable logging for the NAT rule"
  type        = bool
  default     = false
}

variable "firewall_match" {
  description = "Specifies which addresses the firewall should match (e.g., MATCH_INTERNAL_ADDRESS)"
  type        = string
  default     = "MATCH_INTERNAL_ADDRESS"
}

variable "priority" {
  description = "If an address has multiple NAT rules, the rule with the highest priority is applied. A lower value means a higher precedence for this rule"
  type        = number
  default     = null
}
