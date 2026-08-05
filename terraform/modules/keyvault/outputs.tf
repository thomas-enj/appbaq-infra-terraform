output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "postgresql_secret_ids" {
  value = {
    host              = azurerm_key_vault_secret.postgresql_host.id
    admin_username    = azurerm_key_vault_secret.postgresql_admin_username.id
    admin_password    = azurerm_key_vault_secret.postgresql_admin_password.id
    database_name     = azurerm_key_vault_secret.postgresql_database_name.id
    connection_string = azurerm_key_vault_secret.postgresql_connection_string.id
  }
}
