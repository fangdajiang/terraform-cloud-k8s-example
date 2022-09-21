terraform {
  required_providers {
    asurerm = {
      source = var.TF_REQUIRED_PROVIDER_SOURCE
      version = var.TF_REQUIRED_PROVIDER_VERSION
    }
  }
  required_version = var.TF_REQUIRED_VERSION
}
provider "azurerm" {
#  access_key = var.ALICLOUD_ACCESS_KEY
#  secret_key = var.ALICLOUD_SECRET_KEY
#  region = var.ALICLOUD_REGION
#  profile = var.ALICLOUD_PROFILE
  features {}
  version = "=1.5.0"
}
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  username               = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  password               = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}