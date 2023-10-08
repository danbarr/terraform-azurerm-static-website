variable "prefix" {
  type        = string
  description = "A prefix to add to the storage account name to make it unique. A random number will also be added."
  validation {
    condition     = can(regex("^[a-z0-9]{1,14}$", var.prefix))
    error_message = "Prefix must be 1-14 lowercase alphanumeric characters."
  }
}

variable "location" {
  type        = string
  description = "The region where the resources are created."
  validation {
    condition     = can(regex("us[0-9]?$", var.location))
    error_message = "Only US regions allowed."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the static website storage will be created."
}

variable "env" {
  type        = string
  description = "Value for the environment tag."
  validation {
    condition     = contains(["dev", "test", "prod", "demo"], var.env)
    error_message = "Environment must be one of: dev, test, prod, demo."
  }
}

variable "department" {
  type        = string
  description = "Value for the department tag."
  default     = "WebDev"
}

variable "storage_kind" {
  type        = string
  description = "Kind of storage account to create."
  default     = "StorageV2"
  validation {
    condition     = contains(["StorageV2", "BlockBlobStorage"], var.storage_kind)
    error_message = "Kind must be StorageV2 or BlockBlobStorage."
  }
}

variable "storage_tier" {
  type        = string
  description = "Tier of the storage account."
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_tier)
    error_message = "Tier must be Standard or Premium"
  }
}

variable "storage_replication_type" {
  type        = string
  description = "Type of replication to use for the storage account."
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS"], var.storage_replication_type)
    error_message = "Please use LRS or GRS only"
  }
}

variable "delete_retention_days" {
  type = number
  description = "Number of days to retain deleted objects."
  default = 7
  validation {
    condition     = var.delete_retention_days >= 1 && var.delete_retention_days <= 365
    error_message = "Retention days must be between 1 and 365 days."
  }
}
