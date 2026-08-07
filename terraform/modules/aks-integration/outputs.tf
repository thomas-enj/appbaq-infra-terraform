output "aks_name" {
  description = "Name of the integrated AKS cluster."
  value       = data.azurerm_kubernetes_cluster.shared.name
}

output "aks_resource_group_name" {
  description = "Resource group name of the integrated AKS cluster."
  value       = data.azurerm_kubernetes_cluster.shared.resource_group_name
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet identity granted AcrPull."
  value       = data.azurerm_kubernetes_cluster.shared.kubelet_identity[0].object_id
}

output "acr_pull_role_assignment_id" {
  description = "Role assignment ID for AcrPull granted to AKS kubelet identity."
  value       = azurerm_role_assignment.aks_acr_pull.id
}
