output "key_vault_name" {
  description = "Name of the Azure Key Vault used to store PostgreSQL connection secrets."
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault used to resolve secret references."
  value       = azurerm_key_vault.kv.vault_uri
}

output "postgresql_secret_ids" {
  description = "Map of Key Vault secret resource IDs containing PostgreSQL connection data."
  value = {
    host              = azurerm_key_vault_secret.postgresql_host.id
    admin_username    = azurerm_key_vault_secret.postgresql_admin_username.id
    admin_password    = azurerm_key_vault_secret.postgresql_admin_password.id
    database_name     = azurerm_key_vault_secret.postgresql_database_name.id
    connection_string = azurerm_key_vault_secret.postgresql_connection_string.id
  }
}

output "backend_secret_ids" {
  description = "Map of Key Vault secret resource IDs matching backend Helm secret object names."
  value = {
    spring_datasource_url      = azurerm_key_vault_secret.spring_datasource_url.id
    spring_datasource_username = azurerm_key_vault_secret.spring_datasource_username.id
    spring_datasource_password = azurerm_key_vault_secret.spring_datasource_password.id
    redis_hostname             = azurerm_key_vault_secret.redis_hostname.id
    redis_password             = azurerm_key_vault_secret.redis_password.id
    backend_api_key            = azurerm_key_vault_secret.backend_api_key.id
    storage_account_name       = azurerm_key_vault_secret.storage_account_name.id
    storage_sas_token          = azurerm_key_vault_secret.storage_sas_token.id
  }
}
