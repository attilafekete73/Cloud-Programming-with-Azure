resource "azurerm_resource_group" "traffic_manager_rg" {
  name     = "rg-traffic-manager"
  location = "West Europe"
}

# Child profile for EU with failover to Asia and US
resource "azurerm_traffic_manager_profile" "eu_profile" {
  name                = "eu-profile"
  resource_group_name = "rg-traffic-manager"
  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "eu-child"
    ttl = 30
  }
  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/healthz"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "eu_primary" {
  name                = "eu-primary"
  profile_id          = azurerm_traffic_manager_profile.eu_profile.id
  target_resource_id  = azurerm_linux_web_app.app-eu.id
  priority            = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "eu_backup_asia" {
  name                = "eu-backup-asia"
  profile_id          = azurerm_traffic_manager_profile.eu_profile.id
  target_resource_id  = azurerm_linux_web_app.app-asia.id
  priority            = 2
}

resource "azurerm_traffic_manager_azure_endpoint" "eu_backup_us" {
  name                = "eu-backup-us"
  profile_id          = azurerm_traffic_manager_profile.eu_profile.id
  target_resource_id  = azurerm_linux_web_app.app-us.id
  priority            = 3
}

# Child profile for Asia with failover for US and EU
resource "azurerm_traffic_manager_profile" "as_profile" {
  name                = "as-profile"
  resource_group_name = "rg-traffic-manager"
  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "as-child"
    ttl = 30
  }
  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/healthz/"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "as_primary" {
  name                = "as-primary"
  profile_id          = azurerm_traffic_manager_profile.as_profile.id
  target_resource_id  = azurerm_linux_web_app.app-asia.id
  priority            = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "as_backup_us" {
  name                = "as-backup-us"
  profile_id          = azurerm_traffic_manager_profile.as_profile.id
  target_resource_id  = azurerm_linux_web_app.app-us.id
  priority            = 2
}

resource "azurerm_traffic_manager_azure_endpoint" "as_backup_eu" {
  name                = "as-backup-eu"
  profile_id          = azurerm_traffic_manager_profile.as_profile.id
  target_resource_id  = azurerm_linux_web_app.app-eu.id
  priority            = 3
}

# Child profile for US with failover for EU and AS
resource "azurerm_traffic_manager_profile" "us_profile" {
  name                = "us-profile"
  resource_group_name = "rg-traffic-manager"
  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "us-child"
    ttl = 30
  }
  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/healthz"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "us_primary" {
  name                = "us-primary"
  profile_id          = azurerm_traffic_manager_profile.us_profile.id
  target_resource_id  = azurerm_linux_web_app.app-us.id
  priority            = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "us_backup_eu" {
  name                = "us-backup-eu"
  profile_id          = azurerm_traffic_manager_profile.us_profile.id
  target_resource_id  = azurerm_linux_web_app.app-eu.id
  priority            = 2
}

resource "azurerm_traffic_manager_azure_endpoint" "us_backup_as" {
  name                = "us-backup-as"
  profile_id          = azurerm_traffic_manager_profile.us_profile.id
  target_resource_id  = azurerm_linux_web_app.app-asia.id
  priority            = 3
}

# Geo parent profile
resource "azurerm_traffic_manager_profile" "geo_profile" {
  name                = "geo-profile"
  resource_group_name = "rg-traffic-manager"
  traffic_routing_method = "Geographic"
    dns_config {
    relative_name = "mygeoapp"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/healthz"
  }
}

resource "azurerm_traffic_manager_nested_endpoint" "eu_nested" {
  name                = "eu-nested"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_traffic_manager_profile.eu_profile.id
  geo_mappings        = ["GEO-EU", "GEO-ME", "GEO-AF"]
  minimum_child_endpoints = 1
}

resource "azurerm_traffic_manager_nested_endpoint" "asia_nested" {
  name                = "asia-nested"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_traffic_manager_profile.as_profile.id
  geo_mappings        = ["GEO-AS", "GEO-AN", "GEO-AP"]
  minimum_child_endpoints = 1
}

resource "azurerm_traffic_manager_nested_endpoint" "us_nested" {
  name                = "us-nested"
  profile_id          = azurerm_traffic_manager_profile.geo_profile.id
  target_resource_id  = azurerm_traffic_manager_profile.us_profile.id
  geo_mappings        = ["GEO-NA", "GEO-SA"]
  minimum_child_endpoints = 1
}
