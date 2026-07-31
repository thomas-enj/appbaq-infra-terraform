terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Storage account for the application
resource "azurerm_storage_account" "sa" {
  name                            = "appbaqsa${replace(var.owner, "-", "")}tf"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

# Private container used by QuizResultExportService.
# The backend uploads quiz result JSON blobs with names like results/{sessionId}.json.
resource "azurerm_storage_container" "quiz_results" {
  name                  = "quiz-results"
  storage_account_id    = azurerm_storage_account.sa.name
  container_access_type = "private"
}