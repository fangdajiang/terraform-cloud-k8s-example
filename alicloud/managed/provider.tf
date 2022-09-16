terraform {
  required_providers {
    alicloud = {
      source = var.TF_REQUIRED_PROVIDER_SOURCE
      version = var.TF_REQUIRED_PROVIDER_VERSION
    }
  }
  required_version = var.TF_REQUIRED_VERSION
}
provider "alicloud" {
  access_key = var.ALICLOUD_ACCESS_KEY
  secret_key = var.ALICLOUD_SECRET_KEY
  region = var.ALICLOUD_REGION
  profile = var.ALICLOUD_PROFILE
}
