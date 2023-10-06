terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  timestamp = timestamp()
}

resource "random_integer" "product" {
  min = 0
  max = length(local.hashi_products) - 1
  keepers = {
    "timestamp" = local.timestamp
  }
}

resource "random_integer" "id" {
  min = 100
  max = 999
}

resource "azurerm_storage_account" "website" {
  name                      = "${var.prefix}website${random_integer.id.result}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = var.storage_kind
  account_tier              = var.storage_tier
  account_replication_type  = var.storage_replication_type
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  static_website {
    index_document = "index.html"
  }

  tags = {
    environment = var.env
    department  = var.department
    application = "HashiCafe website"
  }
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.website.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content = templatefile("${path.module}/files/index.html", {
    product_name  = local.hashi_products[random_integer.product.result].name
    product_color = local.hashi_products[random_integer.product.result].color
    product_image = local.hashi_products[random_integer.product.result].image_file
  })
}

resource "azurerm_storage_blob" "images" {
  for_each               = fileset("${path.module}/files/img/", "*.png")
  name                   = "img/${each.value}"
  storage_account_name   = azurerm_storage_account.website.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "image/png"
  source                 = "${path.module}/files/img/${each.value}"
}

locals {
  hashi_products = [
    {
      name       = "Consul"
      color      = "#dc477d"
      image_file = "hashicafe_art_consul.png"
    },
    {
      name       = "HCP"
      color      = "#ffffff"
      image_file = "hashicafe_art_hcp.png"
    },
    {
      name       = "Nomad"
      color      = "#60dea9"
      image_file = "hashicafe_art_nomad.png"
    },
    {
      name       = "Packer"
      color      = "#63d0ff"
      image_file = "hashicafe_art_packer.png"
    },
    {
      name       = "Terraform"
      color      = "#844fba"
      image_file = "hashicafe_art_terraform.png"
    },
    {
      name       = "Vagrant"
      color      = "#2e71e5"
      image_file = "hashicafe_art_vagrant.png"
    },
    {
      name       = "Vault"
      color      = "#ffec6e"
      image_file = "hashicafe_art_vault.png"
    }
  ]
}
