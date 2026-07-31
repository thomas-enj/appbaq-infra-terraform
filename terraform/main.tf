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