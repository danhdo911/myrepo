variable "project_id" {
  description = "The ID of the OpenStack project to apply the quota to"
  type        = string
}

variable "num_keypairs" {
  description = "Number of allowed key pairs"
  type        = number
  default     = 100
}

variable "num_ram" {
  description = "Total amount of RAM (in MB) allowed"
  type        = number
  default     = 51200
}

variable "num_cores" {
  description = "Total number of vCPUs allowed"
  type        = number
  default     = 20
}

variable "num_instance" {
  description = "Maximum number of instances allowed"
  type        = number
  default     = 10
}

variable "num_servergroups" {
  description = "Maximum number of server groups allowed"
  type        = number
  default     = 10
}

variable "num_servergroup_members" {
  description = "Maximum number of members per server group"
  type        = number
  default     = 10
}