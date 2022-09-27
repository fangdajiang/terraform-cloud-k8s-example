
variable "resource_group_name" {
  description = "(Required) The name of the resource group for this project."
  type    = string
  default = "YouTube-Audio"
}

variable "env_subscription_id" {
  description = "(Required) The Azure subscription ID for the solution environment."
  type        = string
}

variable "location" {
  type    = string
  default = "Korea Central"
}
variable storage_account_tier {
  default = "Standard"
  description = "Storage Account Tier"
}

variable account_replication_type {
  default = "LRS"
  description = "Storage Account Replication Type"
}

# Input variable: Name of Storage Account
variable "storage_account_name" {
  description = "The name of the storage account. Must be globally unique, length between 3 and 24 characters and contain numbers and lowercase letters only."
  default     = "mytfstorageaccount"
}

# Input variable: Name of Storage container
variable "container_name" {
  description = "The name of the Blob Storage container."
  default     = "my-terraform-state-container"
}

variable environment {
  default = "dev"
  description = "The environment in which the resources are deployed such as dev, qa, prod"
}

variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "ya-k8s-dns"
}

variable cluster_name {
  default = "ya-k8s-cluster"
}

variable "vnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azurerm_virtual_network_address_space" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["ya-k8s-subnet"]
}

variable "owner" {
  default = "fangdajiang"
}

variable "azurerm_virtual_network_name" {
  name    = "youtube-audio-network"
}

variable "kubernetes_pod_meta_name" {
  name    = "terraform-youtube-audio"
}