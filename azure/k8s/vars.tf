variable "resource_group_name" {
  description = "(Required) The name of the resource group for this project."
  type    = string
  default = "my-terraform-rg"
}

variable "location" {
  type    = string
  default = "Korea Central"
}

variable environment {
  default = "dev"
  description = "The environment in which the resources are deployed such as dev, qa, prod"
}

variable "env_subscription_id" {
  default = "c25a925d-cc97-4808-a6b8-629311c83176"
  description = "(Required) The Azure subscription ID for the solution environment."
  type        = string
}

variable "aks_agent_count" {
  description = "The number of agent nodes for the cluster."
  default = 3
}
variable "aks_agent_vm_size" {
  description = "VM size"
  default     = "Standard_D3_v2"
}
variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
  default     = 40
}
variable "aks_dns_service_ip" {
  description = "DNS server IP address"
  default     = "10.0.0.10"
}
variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}
variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}
variable "tags" {
  type = map(string)

  default = {
    environment = "my-terraform-dev"
    source = "terraform"
  }
}
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "my-k8s-dns"
}

variable cluster_name {
  default = "my-k8s-cluster"
}

variable "azurerm_virtual_network_address_space" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "owner" {
  default = "fangdajiang"
}

variable "azurerm_virtual_network_name" {
  default    = "my-terraform-vnet"
}

variable "kubernetes_pod_meta_name" {
  default    = "terraform-my-pod"
}
