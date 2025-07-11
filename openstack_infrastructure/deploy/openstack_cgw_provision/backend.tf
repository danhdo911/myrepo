terraform {
  backend "s3" {
    bucket = "tfstate"
    endpoints = {
      s3 = "https://api-minio.dev.iij.com.vn"
    }
    key                  = "terraform.tfstate"
    workspace_key_prefix = "openstack_cgw_provision"

    region                      = "main"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}