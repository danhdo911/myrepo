variable "gateway_path" {
  description = "The path of the Tier-0 or Tier-1 Gateway"
  type        = string
}

variable "prefix_list_name" {
  description = "Display name for the prefix list"
  type        = string
}

variable "description" {
  description = "Description of the prefix list"
  type        = string
  default     = ""
}

# variable "action" {
#   description = "Action to take for the prefix match (e.g., PERMIT or DENY)"
#   type        = string
# }

# variable "network" {
#   description = "The IP prefix to match, e.g., 10.10.10.0/24"
#   type        = string
# }

# variable "le" {
#   description = "Optional: Prefix length less than or equal to, between 0-128"
#   type        = number
#   default     = null
# }

# variable "ge" {
#   description = "Optional: Prefix length greater than or equal to, between 0-128"
#   type        = number
#   default     = null
# }

variable "scope" {
  description = "Scope of the tag"
  type        = string
  default     = null
}

variable "tag" {
  description = "Value of the tag"
  type        = string
  default     = null
}

variable "prefixes" {
  description = "List of prefix"
  type        = list(object({
    action    = string
    network   = optional(string, null)
    le        = optional(number, null)
    ge        = optional(number, null)
 }))
}