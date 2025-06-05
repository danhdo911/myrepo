variable "vcd_org" {
  description = "The name of organization"
  type        = string
}

variable "edge_gateway_id" {
  description = "The ID of the NSX-T edge gateway"
  type        = string
}

variable "ip_set_name" {
  type = string
}

variable "ip_set_description" {
  type    = string
  default = ""
}

variable "ip_set_subnets" {
  type = list(string)
}