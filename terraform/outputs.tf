output "key_vault_name" {
  description = "Name of the Azure Key Vault storing backend and database secrets."
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault storing backend and database secrets."
  value       = module.keyvault.key_vault_uri
}

output "postgresql_secret_ids" {
  description = "Map of PostgreSQL secret IDs stored in Key Vault."
  value       = module.keyvault.postgresql_secret_ids
}

output "backend_secret_ids" {
  description = "Map of backend secret IDs aligned with Helm values keyVault object names."
  value       = module.keyvault.backend_secret_ids
}
