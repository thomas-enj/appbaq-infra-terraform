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
  kv_owner_token   = substr(local.normalized_owner, 0, min(length(local.normalized_owner), 12))

  postgresql_connection_string = "Host=${var.postgresql_host};Port=5432;Database=${var.postgresql_database_name};Username=${var.postgresql_admin_username};Password=${var.postgresql_admin_password};Ssl Mode=Require;Trust Server Certificate=true;"
  spring_datasource_url        = "jdbc:postgresql://${var.postgresql_host}:5432/${var.postgresql_database_name}?sslmode=require"
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
  numeric = true
}

resource "random_password" "backend_api_key" {
  length           = 48
  special          = true
  override_special = "!@#%*()-_=+"
}

resource "random_password" "redis_password" {
  length           = 36
  special          = true
  override_special = "!@#%*()-_=+"
}

data "azurerm_storage_account_sas" "backend_blob_sas" {
  connection_string = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key};EndpointSuffix=core.windows.net"
  https_only        = true

  # Long-lived SAS kept in Key Vault for backend upload/download operations.
  start  = "2026-01-01"
  expiry = "2030-01-01"

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_key_vault" "kv" {
  name                          = "baqkv${local.kv_owner_token}${random_string.suffix.result}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = false
  enabled_for_disk_encryption   = false
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_key_vault_access_policy" "current_principal" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

resource "azurerm_key_vault_secret" "postgresql_host" {
  name         = "postgresql-host"
  value        = var.postgresql_host
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "postgresql_admin_username" {
  name         = "postgresql-admin-username"
  value        = var.postgresql_admin_username
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  name         = "postgresql-admin-password"
  value        = var.postgresql_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "postgresql_database_name" {
  name         = "postgresql-database-name"
  value        = var.postgresql_database_name
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "postgresql_connection_string" {
  name         = "postgresql-connection-string"
  value        = local.postgresql_connection_string
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "spring_datasource_url" {
  name         = "spring-datasource-url"
  value        = local.spring_datasource_url
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "spring_datasource_username" {
  name         = "spring-datasource-username"
  value        = var.postgresql_admin_username
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "spring_datasource_password" {
  name         = "spring-datasource-password"
  value        = var.postgresql_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "redis_hostname" {
  name         = "redis-hostname"
  value        = var.redis_hostname
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "redis_password" {
  name         = "redis-password"
  value        = random_password.redis_password.result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "backend_api_key" {
  name         = "backend-api-key"
  value        = random_password.backend_api_key.result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "storage_account_name" {
  name         = "storage-account-name"
  value        = var.storage_account_name
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}

resource "azurerm_key_vault_secret" "storage_sas_token" {
  name         = "storage-sas-token"
  value        = data.azurerm_storage_account_sas.backend_blob_sas.sas
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "text/plain"
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.current_principal]
}
