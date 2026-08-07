terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

locals {
  normalized_owner = replace(var.owner, "-", "")
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
  numeric = true
}

# Azure Container Registry storing Docker images for the application workloads.
resource "azurerm_container_registry" "acr" {
  name                          = "baqacr${local.normalized_owner}${random_string.suffix.result}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.container_registry_sku
  admin_enabled                 = var.container_registry_admin_enabled
  public_network_access_enabled = true
  tags                          = var.tags
}
