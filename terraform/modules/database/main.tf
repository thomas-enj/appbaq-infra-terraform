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

resource "random_password" "postgres_admin_password" {
  length           = 24
  special          = true
  override_special = "!@#%*()-_=+"
}

# Dedicated network for PostgreSQL Flexible Server private access.
resource "azurerm_virtual_network" "database" {
  name                = "baq-vnet-db-${var.owner}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.database_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "database" {
  name                 = "baq-snet-db-${var.owner}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.database.name
  address_prefixes     = [var.database_subnet_cidr]

  delegation {
    name = "postgresql-flexible-delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "baq-pg-${local.normalized_owner}-${random_string.suffix.result}.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                 = "baq-pg-dns-link-${var.owner}"
  private_dns_zone_id  = azurerm_private_dns_zone.postgresql.id
  virtual_network_id   = azurerm_virtual_network.database.id
  registration_enabled = false
  tags                 = var.tags
}

resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                   = "baq-pg-${local.normalized_owner}-${random_string.suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  delegated_subnet_id    = azurerm_subnet.database.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgresql.id
  administrator_login    = var.postgresql_admin_username
  administrator_password = random_password.postgres_admin_password.result
  sku_name               = var.postgresql_sku_name
  storage_mb             = var.postgresql_storage_mb
  backup_retention_days  = var.postgresql_backup_retention_days

  public_network_access_enabled = false
  zone                          = var.postgresql_zone
  tags                          = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgresql]
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.postgresql_database_name
  server_id = azurerm_postgresql_flexible_server.postgresql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
