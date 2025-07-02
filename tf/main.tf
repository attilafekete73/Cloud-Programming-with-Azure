variable "eu_location" {
  description = "North Europe"
  type = string
}

variable "as_location" {
  description = "Southeast Asia"
  type = string
}

variable "us_location" {
  description = "West US 2"
  type = string
}

variable "subscription_id" {
  description = "get subscription ID"
  type        = string
}

variable "github_token" {
  type = string
}

variable "us-appname" {
  type = string
  default = "cloudprogrammingproject-3628800-us"
}

variable "eu-appname" {
  type = string
  default = "cloudprogrammingproject-3628800-eu"
}

variable "as-appname" {
  type = string
  default = "cloudprogrammingproject-3628800-as"
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
    storage_account_name = "tfstate3628800"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_app_service_source_control_token" "github" {
  type = "GitHub"
  token = var.github_token
}

