terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

# Azure Managed Redis instance for caching and session management.
resource "azurerm_managed_redis" "redis" {
  name                  = "baqred${replace(var.owner, "-", "")}tf"
  location              = var.location
  resource_group_name   = var.resource_group_name
  sku_name              = "Balanced_B0"
  public_network_access = "Enabled"
  tags                  = var.tags

  # Required by the provider when creating a new Managed Redis instance.
  default_database {}
}
