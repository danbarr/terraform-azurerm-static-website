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

run "unit_tests" {
  command = plan

  variables {
    resource_group_name   = var.resource_group_name
    delete_retention_days = 14
  }

  assert {
    condition     = azurerm_storage_account.website.public_network_access_enabled == true
    error_message = "Public access is not enabled."
  }
  assert {
    condition     = azurerm_storage_account.website.blob_properties[0].delete_retention_policy[0].days == var.delete_retention_days
    error_message = "Blob deletion retention days doesn't match input."
  }
  assert {
    condition     = azurerm_storage_account.website.blob_properties[0].container_delete_retention_policy[0].days == var.delete_retention_days
    error_message = "Container deletion retention days doesn't match input."
  }

}

run "input_validation" {
  command = plan

  # Invalid values
  variables {
    prefix                   = "InvalidPrefix"
    location                 = "australia"
    env                      = "sandbox"
    storage_kind             = "FileStorage"
    storage_tier             = "Invalid"
    storage_replication_type = "RAGRS"
    delete_retention_days    = 400
  }

  expect_failures = [
    var.prefix,
    var.location,
    var.env,
    var.storage_kind,
    var.storage_tier,
    var.storage_replication_type,
    var.delete_retention_days
  ]
}

run "setup_resource_group" {
  command = apply

  variables {
    location            = var.location
    resource_group_name = "tftest-temporary"
  }

  module {
    source = "./tests/setup-rg"
  }
}

run "e2e_test" {
  command = apply

  variables {
    resource_group_name = run.setup_resource_group.resource_group_name
  }

  assert {
    condition     = startswith(azurerm_storage_account.website.name, "tftestwebsite")
    error_message = "Storage account name didn't match the expected value."
  }

  assert {
    condition     = azurerm_storage_account.website.access_tier == "Hot"
    error_message = "Unexpected access tier."
  }
}

run "canary_file" {
  command = apply

  variables {
    storage_account_name = run.e2e_test.storage_account_name
  }

  module {
    source = "./tests/canary_file"
  }

  assert {
    condition     = data.azurerm_storage_blob.canary.content_md5 == filemd5("./tests/canary_file/canary.txt")
    error_message = "The canary file checksum is invalid - something is very wrong."
  }
}
