output "key_vault_name" {
  description = "Name of the Azure Key Vault storing backend and database secrets."
  value       = module.keyvault.key_vault_name
}

output "container_registry_login_server" {
  description = "Login server endpoint of the Azure Container Registry."
  value       = module.container.container_registry_login_server
}

output "shared_aks_name" {
  description = "Name of the shared AKS cluster integrated with ACR pull permissions."
  value       = module.aks_integration.aks_name
}
