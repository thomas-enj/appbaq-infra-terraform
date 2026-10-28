variable "owner" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "container_registry_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Basic"
}

variable "container_registry_admin_enabled" {
  description = "Enable admin user on Azure Container Registry"
  type        = bool
  default     = false
}
