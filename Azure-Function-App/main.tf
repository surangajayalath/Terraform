resource "azurerm_resource_group" "my_resource_group" {
  name     = "my_resource_group"
  location = "West Europe"
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.my_resource_group.name
  location                 = azurerm_resource_group.my_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "my_service_plan" {
  name                = "my_service_plan"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "my_function" {
  name                       = "myfunction"
  location                   = azurerm_resource_group.my_resource_group.location
  resource_group_name        = azurerm_resource_group.my_resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.my_service_plan.id
  storage_account_name       = azurerm_storage_account.my_storage_account.id
  storage_account_access_key = azurerm_storage_account.my_storage_account.primary_access_key
  site_config {
    dotnet_framework_version = "v6.0"
  }
}