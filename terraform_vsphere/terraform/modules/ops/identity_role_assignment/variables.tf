variable "group_id" {
  description = "The ID of the group to assign the role to"
  type        = string
}

variable "project_id" {
  description = "The ID of the project where the role will be assigned"
  type        = string
}

variable "role_id" {
  description = "The ID of the role to assign to the group"
  type        = string
}
