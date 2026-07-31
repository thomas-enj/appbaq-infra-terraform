locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "non-production"
      owner       = var.owner
    },
    var.tags
  )
}

### Data sources ###

# Resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

### Storage ###

module "storage" {
  source              = "./modules/storage"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}