output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.postgresql.fqdn
}

output "postgresql_database_name" {
  value = azurerm_postgresql_flexible_server_database.app.name
}
