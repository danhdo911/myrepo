variable "tenant_id" {
    type = string
}

variable "router_name" {
    type = string
}

variable "admin_state_up" {
    type = bool
    default = true
}

variable "external_network_id" {
    type = string
}

variable "enable_snat" {
    type = bool
    default = true
}

variable "external_ip_address" {
    type = string
    default = null
}

variable "external_subnet_id" {
    type = string
    default = null
}