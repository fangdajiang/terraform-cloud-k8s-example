output "public_ip" {
  value = azurerm_public_ip.tfexample.ip_address
}

output "blob_storage_container" {
  value = "https://${data.azurerm_storage_account.terraform_state.name}.blob.core.windows.net/${data.azurerm_storage_container.terraform_state.name}/"
}