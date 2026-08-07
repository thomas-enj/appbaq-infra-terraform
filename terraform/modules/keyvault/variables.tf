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

variable "postgresql_host" {
  type = string
}

variable "postgresql_admin_username" {
  type = string
}

variable "postgresql_admin_password" {
  type      = string
  sensitive = true
}

variable "postgresql_database_name" {
  type = string
}

variable "redis_hostname" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_access_key" {
  type      = string
  sensitive = true
}

variable "frontend_ci_kv_reader_object_ids" {
  description = "Object IDs allowed to read Key Vault secrets from frontend CI pipeline."
  type        = list(string)
  default     = []
}
