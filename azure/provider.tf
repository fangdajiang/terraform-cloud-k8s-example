# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 1.0.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
  }
}
provider "azurerm" {
#  access_key = var.ALICLOUD_ACCESS_KEY
#  secret_key = var.ALICLOUD_SECRET_KEY
#  region = var.ALICLOUD_REGION
#  profile = var.ALICLOUD_PROFILE
  features {}
  version = "=1.5.0"
  subscription_id = var.env_subscription_id
}
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  username               = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  password               = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}