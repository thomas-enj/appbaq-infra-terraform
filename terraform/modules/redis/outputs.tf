output "redis_cache_name" {
  value = azurerm_managed_redis.redis.name
}

output "redis_hostname" {
  value = azurerm_managed_redis.redis.hostname
}

output "redis_ssl_port" {
  value = azurerm_managed_redis.redis.default_database[0].port
}

output "redis_primary_access_key" {
  value     = azurerm_managed_redis.redis.default_database[0].primary_access_key
  sensitive = true
}

output "redis_id" {
  value = azurerm_managed_redis.redis.id
}
