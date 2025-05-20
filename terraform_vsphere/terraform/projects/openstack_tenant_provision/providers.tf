terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }
  }
}

provider "openstack" {
  user_name   = "danhdo"
  tenant_name = "admin"
  password    = "P@ssw0rd"
  auth_url    = "https://public.dd-iaas.local:5000"
  region      = "RegionOne"
}