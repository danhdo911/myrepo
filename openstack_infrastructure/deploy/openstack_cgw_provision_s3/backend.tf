terraform {
  backend "s3" {
    bucket               = "dd-iij-terraform-bucket"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "openstack_cgw_provision"

    profile = "default_dev_tfstate"
  }
}
