variable "user_name" {
  type        = string
  description = "Tenant Admin Name"
  sensitive   = true
}

variable "user_password" {
  type        = string
  description = "Tenant Admin Password"
  sensitive   = true
}

variable "user_role" {
  type        = string
  description = "Role assignment for Tenant Admin"
  default     = "manager"
}