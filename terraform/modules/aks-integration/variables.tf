variable "aks_resource_group_name" {
  description = "Resource group name of the existing AKS cluster."
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the existing AKS cluster."
  type        = string
}

variable "shared_aks_vnet_id" {
  description = "Full resource ID of the VNet used by the shared AKS cluster."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+$", var.shared_aks_vnet_id))
    error_message = "shared_aks_vnet_id must be a full Azure virtual network resource ID."
  }
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  type        = string
}

variable "database_vnet_id" {
  description = "Resource ID of the database's dedicated virtual network, to peer with the AKS cluster's VNet."
  type        = string
}

variable "database_vnet_name" {
  description = "Name of the database's dedicated virtual network."
  type        = string
}

variable "database_resource_group_name" {
  description = "Resource group name containing the database VNet and private DNS zone."
  type        = string
}

variable "postgresql_private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL private DNS zone, to link into the AKS cluster's VNet so pods can resolve it."
  type        = string
}
