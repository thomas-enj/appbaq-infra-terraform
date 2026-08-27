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

locals {
  # The AKS data source does not expose a reliable VNet ID for this shared cluster.
  # Parse the explicitly supplied VNet resource ID instead of hardcoding its name.
  aks_vnet_id_parts       = split("/", var.shared_aks_vnet_id)
  aks_vnet_resource_group = local.aks_vnet_id_parts[4]
  aks_vnet_name           = local.aks_vnet_id_parts[8]
  aks_vnet_id             = var.shared_aks_vnet_id
}

# Bidirectional peering so AKS pods can reach the database's private VNet (public network access is
# disabled on the PostgreSQL Flexible Server, see modules/database/main.tf).
resource "azurerm_virtual_network_peering" "db_to_aks" {
  name                         = "peer-db-to-aks"
  resource_group_name          = var.database_resource_group_name
  virtual_network_name         = var.database_vnet_name
  remote_virtual_network_id    = local.aks_vnet_id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "aks_to_db" {
  name                         = "peer-aks-to-db"
  resource_group_name          = local.aks_vnet_resource_group
  virtual_network_name         = local.aks_vnet_name
  remote_virtual_network_id    = var.database_vnet_id
  allow_virtual_network_access = true
}

# The PostgreSQL private DNS zone is only linked to the database VNet by default -- without this,
# AKS pods can route to the server over the peering above but still can't resolve its private FQDN.
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_aks" {
  name                 = "baq-pg-dns-link-aks"
  private_dns_zone_id  = var.postgresql_private_dns_zone_id
  virtual_network_id   = local.aks_vnet_id
  registration_enabled = false
}
