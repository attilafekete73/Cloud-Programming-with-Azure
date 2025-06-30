variable "postfix-asia" {
  description = "Postfix value from GitHub Actions environment variable POSTFIX (using TF_VAR_postfix)"
  type        = string
}

#############################
# Resource Group
#############################

resource "azurerm_resource_group" "rg-asia" {
  name     = "webapp-rg-asia"
  location = "Southeast Asia"  # use the region of your choice
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
  name                = var.as-appname # Updated to use POSTFIX value
  location            = azurerm_resource_group.rg-asia.location
  resource_group_name = azurerm_resource_group.rg-asia.name
  service_plan_id     = azurerm_service_plan.asp-asia.id

  site_config {
    application_stack {
      php_version = "8.3"
    }
  }

  app_settings = {
    # If you have configuration settings, add them here.
    # e.g., "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "WEBSITES_PORT"          = "80"
    "DOCKER_ENABLE_CI"       = "true"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  # Note: source_control block is not supported for azurerm_linux_web_app.
  # For GitHub deployment, use GitHub Actions or other deployment methods.
}

#############################
# App Service Source Control
#############################

resource "azurerm_app_service_source_control" "app_source-asia" {
  app_id  = "/subscriptions/88eaf9d2-b255-412e-a937-141f9281d5bd/resourceGroups/webapp-rg-asia/providers/Microsoft.Web/sites/cloudprogrammingproject-${var.postfix-asia}" # Updated to use POSTFIX value
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
      minimum = "1"
      maximum = "3"
      default = "1"
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

#############################
# Front Door
#############################
resource "azurerm_cdn_frontdoor_origin" "as_origin" {
  name                          = "as-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  host_name                     = "${var.as-appname}.azurewebsites.net"
  http_port                     = 80
  https_port                    = 443
  origin_host_header            = "${var.as-appname}.azurewebsites.net"
  priority                      = 1
  weight                        = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "fd_route_as" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  cdn_frontdoor_origin_ids      = [
    azurerm_cdn_frontdoor_origin.as_origin.id,
    # Add other origins here
  ]
  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = true
}


