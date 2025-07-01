resource "azurerm_resource_group" "traffic_manager_rg" {
  name     = "rg-traffic-manager"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "geo_profile" {
  name                     = "geo-traffic-manager"
  resource_group_name      = azurerm_resource_group.traffic_manager_rg.name
  traffic_routing_method   = "Geographic"

  dns_config {
    relative_name = "mygeoapp"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "eu" {
  name                = "eu-endpoint"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_linux_web_app.app-eu.id
  geo_mappings        = ["GEO-EU", "GEO-ME", "GEO-AF"]
}

resource "azurerm_traffic_manager_azure_endpoint" "asia" {
  name                = "asia-endpoint"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_linux_web_app.app-asia.id
  geo_mappings        = ["GEO-AS", "GEO-AN", "GEO-AP"]
}

resource "azurerm_traffic_manager_azure_endpoint" "us" {
  name                = "us-endpoint"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_linux_web_app.app-us.id
  geo_mappings        = ["GEO-NA", "GEO-SA"]
}