variable "rbac_action" {
    type = string
    description = "Action for the RBAC policy. 'access_as_shared' for permits all projects; 'access_as_external' for specific projects"
    default = "access_as_external"
    validation {
        condition     = contains(["access_as_external", "access_as_shared"], var.rbac_action)
        error_message = "rbac_action must be one of: access_as_external, access_as_shared"
    }
}

variable "object_id" {
    type = string
    description = "The ID of the object_type resource. An object_type of 'network' returns a network ID and an object_type of 'qos_policy' returns a QoS ID"
}

variable "object_type" {
    type = string
    description = "The type of the object that the RBAC policy affects. Can be one of the following: address_scope, address_group, network, qos_policy, security_group, subnetpool or bgpvpn"
    default = "network"
    validation {
        condition     = contains(["address_scope", "address_group", "network", "qos_policy", "security_group", "subnetpool", "bgpvpn"], var.object_type)
        error_message = "object_type must be one of: address_scope, address_group, network, qos_policy, security_group, subnetpool or bgpvpn"
    }
}

variable "target_tenant" {
    type = string
    default = ""
}
