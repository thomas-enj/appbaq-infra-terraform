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

variable "database_vnet_cidr" {
  description = "CIDR block for the dedicated database virtual network."
  type        = string
  default     = "10.50.0.0/16"
}

variable "database_subnet_cidr" {
  description = "CIDR block for the delegated PostgreSQL subnet."
  type        = string
  default     = "10.50.1.0/24"
}

variable "postgresql_admin_username" {
  description = "Administrator login name for PostgreSQL Flexible Server."
  type        = string
  default     = "pgappbaqadmin"
}

variable "postgresql_database_name" {
  description = "Application database name created in the server."
  type        = string
  default     = "appbaq"
}

variable "postgresql_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "Storage size in MB."
  type        = number
  default     = 32768
}

variable "postgresql_backup_retention_days" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "postgresql_zone" {
  description = "Availability zone used for the server deployment."
  type        = string
  default     = "1"
}
