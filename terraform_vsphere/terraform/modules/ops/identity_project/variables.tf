variable "project_name" {
  description = "The name of the OpenStack project to create."
  type        = string
}

variable "project_description" {
  description = "A description for the OpenStack project."
  type        = string
  default     = ""
}

variable "project_enabled" {
  description = "Whether the OpenStack project is enabled. Set to false to disable the project."
  type        = bool
  default     = true
}