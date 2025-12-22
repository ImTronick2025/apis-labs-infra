# Backend configuration for Terraform state
# This stores the state in Azure Storage to enable team collaboration and CI/CD

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateimtronick2025"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
