resource "azurerm_resource_group" "traffic_manager_rg" {
  name     = "traffic-manager"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "geo_profile" {
  name                     = "geo-traffic-manager"
  resource_group_name      = traffic_manager_rg.name
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

resource "azurerm_traffic_manager_endpoint" "europe" {
  name                = "europe-endpoint"
  profile_name        = azurerm_traffic_manager_profile.geo_profile.name
  resource_group_name = azurerm_resource_group.rg.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_app_service.europe_app.id
  endpoint_location   = "West Europe"

  geo_mappings = ["GEO-EU","GEO-ME","GEO-AF"]
}

resource "azurerm_traffic_manager_endpoint" "us" {
  name                = "us-endpoint"
  profile_name        = azurerm_traffic_manager_profile.geo_profile.name
  resource_group_name = azurerm_resource_group.rg.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_app_service.us_app.id
  endpoint_location   = "East US"

  geo_mappings = ["GEO-NA","GEO-SA"]
}

resource "azurerm_traffic_manager_endpoint" "asia" {
  name                = "asia-endpoint"
  profile_name        = azurerm_traffic_manager_profile.geo_profile.name
  resource_group_name = azurerm_resource_group.rg.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_app_service.asia_app.id
  endpoint_location   = "Southeast Asia"

  geo_mappings = ["GEO-AS","GEO-AN","GEO-OC"]
}