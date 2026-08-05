output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.postgresql.fqdn
}

output "postgresql_database_name" {
  value = azurerm_postgresql_flexible_server_database.app.name
}

output "postgresql_admin_username" {
  value = azurerm_postgresql_flexible_server.postgresql.administrator_login
}

output "postgresql_admin_password" {
  value     = random_password.postgres_admin_password.result
  sensitive = true
}
