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

# High-availability for EMEA
resource "azurerm_traffic_manager_profile" "emea_profile" {
  name                     = "emea-priority-profile"
  resource_group_name      = azurerm_resource_group.traffic_manager_rg.name
  traffic_routing_method   = "Priority"

  dns_config {
    relative_name = "emea-nested"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "emea_primary" {
  name                = "emea-primary-endpoint"
  profile_id          = azurerm_traffic_manager_profile.emea_profile.id
  target_resource_id  = azurerm_linux_web_app.app-eu.id
  priority            = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "emea_fallback" {
  name                = "emea-fallback-endpoint"
  profile_id          = azurerm_traffic_manager_profile.emea_profile.id
  target_resource_id  = azurerm_linux_web_app.app-us.id
  priority            = 2
}

resource "azurerm_traffic_manager_nested_endpoint" "emea_nested" {
  name                = "emea-nested-endpoint"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_traffic_manager_profile.emea_profile.id
  endpoint_location   = "West Europe"
  geo_mappings        = ["GEO-EU", "GEO-ME", "GEO-AF"]
  minimum_child_endpoints = 1
}

# High-availability for APAC
resource "azurerm_traffic_manager_profile" "apac_profile" {
  name                     = "apac-priority-profile"
  resource_group_name      = azurerm_resource_group.traffic_manager_rg.name
  traffic_routing_method   = "Priority"

  dns_config {
    relative_name = "apac-nested"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "apac_primary" {
  name                = "apac-primary-endpoint"
  profile_id          = azurerm_traffic_manager_profile.apac_profile.id
  target_resource_id  = azurerm_linux_web_app.app-asia.id
  priority            = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "apac_fallback" {
  name                = "apac-fallback-endpoint"
  profile_id          = azurerm_traffic_manager_profile.apac_profile.id
  target_resource_id  = azurerm_linux_web_app.app-eu.id
  priority            = 2
}

resource "azurerm_traffic_manager_nested_endpoint" "apac_nested" {
  name                = "apac-nested-endpoint"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_traffic_manager_profile.apac_profile.id
  endpoint_location   = "Southeast Asia"
  geo_mappings        = ["GEO-AS", "GEO-AN", "GEO-OC"]
  minimum_child_endpoints = 1
}

# High-availability for AMER
resource "azurerm_traffic_manager_profile" "amer_profile" {
  name                     = "amer-priority-profile"
  resource_group_name      = azurerm_resource_group.traffic_manager_rg.name
  traffic_routing_method   = "Priority"

  dns_config {
    relative_name = "amer-nested"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "amer_primary" {
  name                = "amer-primary-endpoint"
  profile_id          = azurerm_traffic_manager_profile.amer_profile.id
  target_resource_id  = azurerm_linux_web_app.app-us.id
  priority            = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "amer_fallback" {
  name                = "amer-fallback-endpoint"
  profile_id          = azurerm_traffic_manager_profile.amer_profile.id
  target_resource_id  = azurerm_linux_web_app.app-asia.id
  priority            = 2
}

resource "azurerm_traffic_manager_nested_endpoint" "amer_nested" {
  name                = "amer-nested-endpoint"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_traffic_manager_profile.amer_profile.id
  endpoint_location   = "East US"
  geo_mappings        = ["GEO-NA", "GEO-SA"]
  minimum_child_endpoints = 1
}