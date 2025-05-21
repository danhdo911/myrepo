variable "project_id" {
  description = "The ID of the OpenStack project to apply the networking quota to"
  type        = string
}

variable "num_networks" {
  description = "Quota for number of networks"
  type        = number
  default     = 50
}

variable "num_subnet" {
  description = "Quota for number of subnets"
  type        = number
  default     = 20
}

variable "num_subnetpool" {
  description = "Quota for number of subnet pools"
  type        = number
  default     = 2
}

variable "num_ports" {
  description = "Quota for number of ports"
  type        = number
  default     = 500
}

variable "num_router" {
  description = "Quota for number of routers"
  type        = number
  default     = 5
}

variable "num_floatingips" {
  description = "Quota for number of floating IPs"
  type        = number
  default     = 20
}

variable "num_securitygroup" {
  description = "Quota for number of security groups"
  type        = number
  default     = 10
}

variable "num_securitygroup_rule" {
  description = "Quota for number of security group rules"
  type        = number
  default     = 100
}

variable "num_rbac_policy" {
  description = "Quota for number of RBAC policies"
  type        = number
  default     = 10
}
