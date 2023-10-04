# Common values for all test runs
variables {
  prefix              = "tftest"
  location            = "centralus"
  env                 = "demo"
  resource_group_name = "demo-rg"
}

provider "azurerm" {
  features {}
}

run "encryption_valid" {
  variables {
    # Invalid kind/tier combination for infrastructure encryption
    storage_kind = "BlockBlobStorage"
    storage_tier = "Standard"
  }

  command = plan

  expect_failures = [azurerm_storage_account.website]
}
