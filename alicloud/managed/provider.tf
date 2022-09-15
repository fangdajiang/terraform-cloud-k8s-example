terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
      version = "1.185.0"
    }
  }
  required_version = ">= 0.12"
}
provider "alicloud" {
  region = var.ALICLOUD_REGION
  profile = var.ALICLOUD_PROFILE
}
