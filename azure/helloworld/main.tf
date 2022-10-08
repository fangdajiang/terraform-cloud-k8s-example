# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 1.0.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
  }

  # Define Terraform backend using a blob storage container on Microsoft Azure for storing the Terraform state
  backend "azurerm" {
    resource_group_name  = "my-terraform-rg"
    storage_account_name = "fdjtfstorageaccount"
    container_name       = "fdj-terraform-state-container"
    key                  = "terraform.tfstate"
  }
}
# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
}

# Create a Resource Group if it doesn't exist
data "azurerm_resource_group" "tfexample" {
  name     = var.resource_group_name
#  location = "Korea Central"
}
# Create a Storage account
data "azurerm_storage_account" "terraform_state" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.tfexample.name
}

# Create a Storage container
data "azurerm_storage_container" "terraform_state" {
  name                  = var.container_name
  storage_account_name  = data.azurerm_storage_account.terraform_state.name
}
# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "tfexample" {
  name                 = "my-terraform-subnet"
  resource_group_name  = data.azurerm_resource_group.tfexample.name
  virtual_network_name = azurerm_virtual_network.tfexample.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "tfexample" {
  name                = "my-terraform-public-ip"
  location            = data.azurerm_resource_group.tfexample.location
  resource_group_name = data.azurerm_resource_group.tfexample.name
  allocation_method   = "Static"

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Virtual Network
resource "azurerm_virtual_network" "tfexample" {
  name                = "my-terraform-vnet"
  location            = data.azurerm_resource_group.tfexample.location
  resource_group_name = data.azurerm_resource_group.tfexample.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Network Interface
resource "azurerm_network_interface" "tfexample" {
  name                = "my-terraform-nic"
  location            = data.azurerm_resource_group.tfexample.location
  resource_group_name = data.azurerm_resource_group.tfexample.name

  ip_configuration {
    name                          = "my-terraform-nic-ip-config"
    subnet_id                     = azurerm_subnet.tfexample.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfexample.id
  }

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Network Security Group and rule
resource "azurerm_network_security_group" "tfexample" {
  name                = "my-terraform-nsg"
  location            = data.azurerm_resource_group.tfexample.location
  resource_group_name = data.azurerm_resource_group.tfexample.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "tfexample" {
  network_interface_id      = azurerm_network_interface.tfexample.id
  network_security_group_id = azurerm_network_security_group.tfexample.id
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "tfexample" {
  name                            = "my-terraform-vm"
  location                        = data.azurerm_resource_group.tfexample.location
  resource_group_name             = data.azurerm_resource_group.tfexample.name
  network_interface_ids           = [azurerm_network_interface.tfexample.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "terraform-vm"
  admin_username                  = "azureuser"
#  admin_password                  = "Password1234!"
#  disable_password_authentication = false
  # The Azure VM Agent only allows creating SSH Keys at the path /home/{username}/.ssh/authorized_keys - as such this public key will be written to the authorized keys file.
  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa.pub")
    username   = "azureuser"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-terraform-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}