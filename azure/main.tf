# Create a resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.environment
    owner = var.owner
  }
}
# Create a virtual network within the resource group
resource "azurerm_virtual_network" "k8s" {
  name                = var.azurerm_virtual_network_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  address_space       = var.azurerm_virtual_network_address_space
}
resource "random_password" "terraform_vm" {
  length  = 16
  upper = true
  special = true
}
resource "kubernetes_pod" "ya" {
  metadata {
    name = var.kubernetes_pod_meta_name
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"
    }
  }
}
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  default_node_pool {
    name    = ""
    vm_size = ""
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.k8s.name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.account_replication_type
}

resource "random_id" "id" {
  byte_length = 4
}

locals {
  storage_account_name = "terraformstate${lower(random_id.id.hex)}"
  vm_public_dns        = "tfvm-${random_id.id.hex}"
}