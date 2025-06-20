terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }
  }
}

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "opgVQRBUZsnZorjjAHS0vEDmyfePtU3IA9luKYf9"
  auth_url    = "https://public.dd-iaas.local:5000"
  region      = "RegionOne"
}