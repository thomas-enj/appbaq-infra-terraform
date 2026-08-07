terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

data "azurerm_kubernetes_cluster" "shared" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}

# Allow kubelet identity from the shared AKS cluster to pull images from this ACR.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_kubernetes_cluster.shared.kubelet_identity[0].object_id
}
