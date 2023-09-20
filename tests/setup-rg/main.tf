terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

resource "random_integer" "id" {
  min = 100
  max = 999
}

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}-${random_integer.id.result}"
  location = var.location
}
