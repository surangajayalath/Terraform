resource "azurerm_resource_group" "app_grp" {
  name     = "LoadBalancerRG"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "primary_plan" {
  name                = "primary-plan100001"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.app_grp.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "primary_webapp" {
  name                = "primarywebapp"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.app_grp.name
  app_service_plan_id = azurerm_app_service_plan.primary_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  source_control {
    repo_url = "https://github.com/surangajayalath/Jenkins-Test.git"
    branch = "main"
    manual_integration = true
    use_mercurial = false
  }
}

resource "azurerm_app_service_plan" "secondary_plan" {
  name                = "secondary-plan"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.app_grp.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "secondary_webapp" {
  name                = "secondarywebapp"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.app_grp.name
  app_service_plan_id = azurerm_app_service_plan.primary_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  source_control {
    repo_url = "https://github.com/surangajayalath/Jenkins-Test.git"
    branch = "main"
    manual_integration = true
    use_mercurial = false
  }
}

resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                   = "traffic_manager"
  resource_group_name    = azurerm_resource_group.app_grp.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "traffic_manager"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "primary_endpoint" {
  name               = "primary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.traffic_manager.id
  weight             = 100
  priority           = 1
  target_resource_id = azurerm_app_service.primary_webapp.id
}

resource "azurerm_traffic_manager_azure_endpoint" "secondary_endpoint" {
  name               = "secondary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.traffic_manager.id
  weight             = 100
  priority           = 2
  target_resource_id = azurerm_app_service.secondary_webapp.id
}