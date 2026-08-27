locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "non-production"
      owner       = var.owner
    },
    var.tags
  )
}

### Data sources ###

# Resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

### Storage ###

module "storage" {
  source              = "./modules/storage"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}

### Container Registry ###

module "container" {
  source              = "./modules/container"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags

  container_registry_sku           = var.container_registry_sku
  container_registry_admin_enabled = var.container_registry_admin_enabled
}

### AKS Integration ###

module "aks_integration" {
  source = "./modules/aks-integration"

  aks_resource_group_name = var.shared_aks_resource_group_name
  aks_cluster_name        = var.shared_aks_cluster_name
  shared_aks_vnet_id      = var.shared_aks_vnet_id
  acr_id                  = module.container.container_registry_id

  database_vnet_id               = module.database.vnet_id
  database_vnet_name             = module.database.vnet_name
  database_resource_group_name   = data.azurerm_resource_group.rg.name
  postgresql_private_dns_zone_id = module.database.private_dns_zone_id
}

### Redis ###

module "redis" {
  source              = "./modules/redis"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}

### Database ###

module "database" {
  source              = "./modules/database"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags

  database_vnet_cidr               = var.database_vnet_cidr
  database_subnet_cidr             = var.database_subnet_cidr
  postgresql_admin_username        = var.postgresql_admin_username
  postgresql_database_name         = var.postgresql_database_name
  postgresql_version               = var.postgresql_version
  postgresql_sku_name              = var.postgresql_sku_name
  postgresql_storage_mb            = var.postgresql_storage_mb
  postgresql_backup_retention_days = var.postgresql_backup_retention_days
  postgresql_zone                  = var.postgresql_zone
}

### Key Vault ###

module "keyvault" {
  source              = "./modules/keyvault"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags

  postgresql_host                  = module.database.postgresql_fqdn
  postgresql_admin_username        = module.database.postgresql_admin_username
  postgresql_admin_password        = module.database.postgresql_admin_password
  postgresql_database_name         = module.database.postgresql_database_name
  redis_hostname                   = module.redis.redis_hostname
  redis_ssl_port                   = module.redis.redis_ssl_port
  storage_account_name             = module.storage.storage_account_name
  storage_account_access_key       = module.storage.storage_account_primary_access_key
  frontend_ci_kv_reader_object_ids = var.frontend_ci_kv_reader_object_ids
}