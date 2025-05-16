variable "port_profile_name" {
  description = "The name of the NSX-T application port profile"
  type        = string
}

variable "port_profile_description" {
  description = "Description for the port profile"
  type        = string
  default     = ""
}

variable "port_protocol" {
  description = "The protocol used (e.g., TCP, UDP)"
  type        = string
  validation {
    condition     = contains(["TCP", "UDP"], var.port_protocol)
    error_message = "Protocol must be one of: TCP, UDP."
  }
}

variable "port_app" {
  description = "List of application ports"
  type        = list(string)
}

variable "profile_scope" {
  description = "Application Port Profile scope (e.g., TENANT, PROVIDER)"
  type        = string
  default     = "TENANT"
}
