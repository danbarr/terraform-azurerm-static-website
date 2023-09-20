variables {
  prefix              = "tftest"
  location            = "centralus"
  env                 = "demo"
  resource_group_name = "dbarr-demo"
}

provider "azurerm" {
  features {}
}

run "unit_tests" {
  command = plan

  assert {
    condition     = azurerm_storage_account.website.public_network_access_enabled == true
    error_message = "Public access is not enabled."
  }

}

run "input_validation" {
  command = plan

  # Invalid values
  variables {
    prefix                   = "InvalidPrefix"
    location                 = "france"
    env                      = "sandbox"
    storage_kind             = "FileStorage"
    storage_tier             = "Invalid"
    storage_replication_type = "RAGRS"
  }

  expect_failures = [
    var.prefix,
    var.location,
    var.env,
    var.storage_kind,
    var.storage_tier,
    var.storage_replication_type,
  ]
}

run "e2e_test" {
  command = apply

  variables {
    prefix = "tfteste2e"
  }

  assert {
    condition     = startswith(azurerm_storage_account.website.name, "tfteste2ewebsite")
    error_message = "Storage account name didn't match the expected value."
  }

  assert {
    condition     = azurerm_storage_account.website.access_tier == "Hot"
    error_message = "Unexpected access tier."
  }
}
