provider "azurerm" {
  features {}
  subscription_id = "88eaf9d2-b255-412e-a937-141f9281d5bd"
}

provider "random" {
  # using default configuration
}

resource "random_integer" "six_digit" {
  min = 100000
  max = 999999
}

#############################
# Resource Group
#############################

resource "azurerm_resource_group" "rg" {
  name     = "webapp-rg"
  location = "West Europe"  # use the region of your choice
}

#############################
# App Service Plan (now Service Plan)
#############################

resource "azurerm_service_plan" "asp" {
  name                = "webapp-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name = "S1"
}

#############################
# App Service (Frontend & Backend)
#############################

resource "azurerm_linux_web_app" "app" {
  name                = "cloudprogrammingproject-${random_integer.six_digit.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  client_certificate_exclusion_paths = ""
  hosting_environment_id = ""
  id                  = "/subscriptions/88eaf9d2-b255-412e-a937-141f9281d5bd/resourceGroups/webapp-rg/providers/Microsoft.Web/sites/cloudprogrammingproject-${random_integer.six_digit.result}"
  virtual_network_subnet_id = ""
  zip_deploy_file = ""

  site_config {
    api_definition_url = ""
    api_management_api_id = ""
    app_command_line = ""
    container_registry_managed_identity_client_id = ""
    health_check_path = ""
    application_stack {
      php_version = "8.3"
      docker_image_name = ""
      docker_registry_url = ""
      docker_registry_username = ""
      dotnet_version = ""
      go_version = ""
      java_server = ""
      java_server_version = ""
      java_version = ""
      node_version = ""
      python_version = ""
      ruby_version = ""
    }
  }

  app_settings = {
    # If you have configuration settings, add them here.
    # e.g., "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "WEBSITES_PORT" = "80"
    "DOCKER_ENABLE_CI" = "true"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  # Note: source_control block is not supported for azurerm_linux_web_app.
  # For GitHub deployment, use GitHub Actions or other deployment methods.
}

#############################
# App Service Source Control
#############################

resource "azurerm_app_service_source_control" "app_source" {
  app_id                 = "/subscriptions/88eaf9d2-b255-412e-a937-141f9281d5bd/resourceGroups/webapp-rg/providers/Microsoft.Web/sites/cloudprogrammingproject-${random_integer.six_digit.result}"
  branch                = "main"
  id                   = "/subscriptions/88eaf9d2-b255-412e-a937-141f9281d5bd/resourceGroups/webapp-rg/providers/Microsoft.Web/sites/cloudprogrammingproject-${random_integer.six_digit.result}"
  repo_url             = "https://github.com/attilafekete73/Cloud-Programming-with-Azure"
  rollback_enabled = false
  scm_type = "GitHubAction"
  use_local_git = false
  use_manual_integration = false
  use_mercurial = false
  uses_github_action = true
}

#############################
# Autoscale Settings
#############################

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_service_plan.asp.id
  enabled             = true

  profile {
    name = "defaultProfile"

    capacity {
      minimum = "1"
      maximum = "3"
      default = "1"
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}



