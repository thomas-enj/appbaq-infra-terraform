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

output "vnet_id" {
  description = "Resource ID of the dedicated database virtual network, for peering."
  value       = azurerm_virtual_network.database.id
}

output "vnet_name" {
  description = "Name of the dedicated database virtual network."
  value       = azurerm_virtual_network.database.name
}

output "private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL private DNS zone, to link into other VNets that need to resolve it."
  value       = azurerm_private_dns_zone.postgresql.id
}
