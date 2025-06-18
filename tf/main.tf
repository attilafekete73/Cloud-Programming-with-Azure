terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate28091" # replace with actual name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}