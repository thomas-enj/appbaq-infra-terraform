output "key_vault_uri" {
  description = "URI of the Azure Key Vault storing PostgreSQL connection secrets."
  value       = module.keyvault.key_vault_uri
}
