terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

resource "azurerm_storage_blob" "canary" {
  name                   = "canary.txt"
  storage_account_name   = var.storage_account_name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/plain"
  source                 = "./canary.txt"
}

data "azurerm_storage_blob" "canary" {
  name                   = azurerm_storage_blob.canary.name
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_blob.canary.storage_container_name
  depends_on             = [azurerm_storage_blob.canary]
}
