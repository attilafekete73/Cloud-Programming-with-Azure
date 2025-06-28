variable "subscription_id" {
  description = "get subscription ID"
  type        = string
}

variable "github_token" {
  type = string
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate28091" # replace with actual name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_app_service_source_control_token" "github" {
  type = "GitHub"
  token = var.github_token
}