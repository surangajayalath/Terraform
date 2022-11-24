# https://youtu.be/Fr4GVOxKo2Y?list=PLLc2nQDXYMHowSZ4Lkq2jnZ0gsJL3ArAw
resource "azurerm_resource_group" "web_apps" {
  name     = "web_apps"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "app_plan" {
  name                = "app_plan"
  location            = azurerm_resource_group.web_apps.location
  resource_group_name = azurerm_resource_group.web_apps.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "webapp"
  location            = azurerm_resource_group.web_apps.location
  resource_group_name = azurerm_resource_group.web_apps.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  source_control {
    repo_url = "url here"
    branch = "master"
    manual_intergration = true
    use_mercurial = false
  }

}