#############################
# Resource Group
#############################

resource "azurerm_resource_group" "rg-us" {
  name     = "webapp-rg-us"
  location = "West US 2"
}

#############################
# App Service Plan (now Service Plan)
#############################

resource "azurerm_service_plan" "asp-us" {
  name                = "webapp-asp-us"
  location            = azurerm_resource_group.rg-us.location
  resource_group_name = azurerm_resource_group.rg-us.name
  os_type             = "Linux"
  sku_name = "S1"
}

#############################
# App Service (Frontend & Backend)
#############################

resource "azurerm_linux_web_app" "app-us" {
  name                = var.us-appname
  location            = azurerm_resource_group.rg-us.location
  resource_group_name = azurerm_resource_group.rg-us.name
  service_plan_id     = azurerm_service_plan.asp-us.id

  site_config {
    application_stack {
      php_version = "8.3"
    }
  }

  app_settings = {
    "WEBSITES_PORT"          = "80"
    "DOCKER_ENABLE_CI"       = "true"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "REGION"                  = "US"
  }
}

#############################
# App Service Source Control
#############################

resource "azurerm_app_service_source_control" "app_source-us" {
  app_id  = "/subscriptions/88eaf9d2-b255-412e-a937-141f9281d5bd/resourceGroups/webapp-rg-us/providers/Microsoft.Web/sites/${var.us-appname}"
  branch  = "main"
  repo_url = "https://github.com/attilafekete73/Cloud-Programming-with-Azure"
  depends_on = [
    azurerm_app_service_source_control_token.github,
    azurerm_linux_web_app.app-us
  ]

}

#############################
# Autoscale Settings
#############################

resource "azurerm_monitor_autoscale_setting" "autoscale-us" {
  name                = "autoscale-webapp-us"
  location            = azurerm_resource_group.rg-us.location
  resource_group_name = azurerm_resource_group.rg-us.name
  target_resource_id  = azurerm_service_plan.asp-us.id
  enabled             = true

  profile {
    name = "defaultProfile"

    capacity {
      minimum = "2"
      maximum = "3"
      default = "2"
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp-us.id
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
        metric_resource_id = azurerm_service_plan.asp-us.id
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