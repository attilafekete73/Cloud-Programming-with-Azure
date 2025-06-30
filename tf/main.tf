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
    storage_account_name = "tfstate28091" # replace with actual name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_app_service_source_control_token" "github" {
  type = "GitHub"
  token = var.github_token
}

resource "azurerm_resource_group" "fd_rg" {
  name = "frontdoor_rg"
  location = "West Europe"

}
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "my-frontdoor-profile"
  resource_group_name = "frontdoor-rg"
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                     = "my-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}

resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group" {
  name                     = "my-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
    interval_in_seconds = 120
  }
}
