variable "project_id" {
  description = "The ID of the default project to assign the user to."
  type        = string
}

variable "user_name" {
  description = "The name of the user to create."
  type        = string
}

variable "user_password" {
  description = "The password for the user."
  type        = string
  sensitive   = true
}

variable "description" {
  description = "A description of the user."
  type        = string
  default     = ""
}

variable "email" {
  description = "The email of the user."
  type        = string
  default     = ""
}