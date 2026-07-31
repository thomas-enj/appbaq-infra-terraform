terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

# Azure managed Redis instance for the application cache/session needs.
resource "azurerm_redis_cache" "redis" {
  name                = "baqred${replace(var.owner, "-", "")}tf"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"
  enable_non_ssl_port = false
  tags                = var.tags
}
