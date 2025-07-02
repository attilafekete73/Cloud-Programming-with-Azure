#############################
# Resource Group
#############################

resource "azurerm_resource_group" "rg-asia" {
  name     = "webapp-rg-asia"
  location = "Southeast Asia"
}

#############################
# App Service Plan (now Service Plan)
#############################

resource "azurerm_service_plan" "asp-asia" {
  name                = "webapp-asp-asia"
  location            = azurerm_resource_group.rg-asia.location
  resource_group_name = azurerm_resource_group.rg-asia.name
  os_type             = "Linux"
  sku_name = "S1"
}

#############################
# App Service (Frontend & Backend)
#############################

resource "azurerm_linux_web_app" "app-asia" {
  name                = var.as-appname
  location            = azurerm_resource_group.rg-asia.location
  resource_group_name = azurerm_resource_group.rg-asia.name
  service_plan_id     = azurerm_service_plan.asp-asia.id

  site_config {
    application_stack {
      php_version = "8.3"
    }
  }

  app_settings = {
    "WEBSITES_PORT"          = "80"
    "DOCKER_ENABLE_CI"       = "true"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "REGION"                  = "AS"

  }
}

#############################
# App Service Source Control
#############################

resource "azurerm_app_service_source_control" "app_source-asia" {
  app_id  = "/subscriptions/88eaf9d2-b255-412e-a937-141f9281d5bd/resourceGroups/webapp-rg-asia/providers/Microsoft.Web/sites/${var.as-appname}"
  branch  = "main"
  repo_url = "https://github.com/attilafekete73/Cloud-Programming-with-Azure"
  depends_on = [
    azurerm_app_service_source_control_token.github
  ]
}

#############################
# Autoscale Settings
#############################

resource "azurerm_monitor_autoscale_setting" "autoscale-asia" {
  name                = "autoscale-webapp-asia"
  location            = azurerm_resource_group.rg-asia.location
  resource_group_name = azurerm_resource_group.rg-asia.name
  target_resource_id  = azurerm_service_plan.asp-asia.id
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
        metric_resource_id = azurerm_service_plan.asp-asia.id
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
        metric_resource_id = azurerm_service_plan.asp-asia.id
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

