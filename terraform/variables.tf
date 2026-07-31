variable "owner" {
  description = "Learner identifier (firstname-lastname, lowercase, hyphens). Ex: john-doe"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+[a-z0-9]$", var.owner))
    error_message = "owner must be lowercase, letters, digits and hyphens only."
  }
}

variable "resource_group_name" {
  description = "Name of the Resource Group pre-created by the trainer. Ex: rg-john-doe"
  type        = string
}

# variable "location" {
#   description = "Azure region for resources"
#   type        = string
#   default     = "francecentral"
# }

# variable "shared_rg_name" {
#   description = "Resource Group containing the shared App Service plan"
#   type        = string
#   default     = "rg-shared-prf2026"
# }

variable "tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

variable "database_vnet_cidr" {
  description = "CIDR block for the dedicated database virtual network"
  type        = string
  default     = "10.50.0.0/16"
}

variable "database_subnet_cidr" {
  description = "CIDR block for the delegated PostgreSQL subnet"
  type        = string
  default     = "10.50.1.0/24"
}

variable "postgresql_admin_username" {
  description = "Administrator login for PostgreSQL Flexible Server"
  type        = string
  default     = "pgappbaqadmin"
}

variable "postgresql_database_name" {
  description = "Application database name in PostgreSQL"
  type        = string
  default     = "appbaqdb"
}

variable "postgresql_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage size in MB"
  type        = number
  default     = 32768
}

variable "postgresql_backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "postgresql_zone" {
  description = "Availability zone for PostgreSQL Flexible Server"
  type        = string
  default     = "1"
}