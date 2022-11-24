resource "azurerm_resource_group" "app-grp" {
   name = "app-grp"
   location = "North Europe"
 }

resource "azurerm_storage_account" "storage_Account" {
  name                     = "mystorageaccount19970727"
  resource_group_name      = "app-grp"
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage_Account.name
  container_access_type = "private"
}

# This is used to upload a local file onto the container
resource "azurerm_storage_blob" "sample" {
  name                   = "sample.txt"
  storage_account_name   = azurerm_storage_account.storage_Account.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "sample.txt"
  depends_on = [
    azurerm_storage_container.data
  ]
}