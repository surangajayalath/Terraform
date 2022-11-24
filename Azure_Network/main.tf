resource "azurerm_resource_group" "mynetworks" {
  name     = "mynetworks"
  location = "West Europe"
}

resource "azurerm_network_security_group" "network_security" {
  name                = "network_security"
  location            = azurerm_resource_group.mynetworks.location
  resource_group_name = azurerm_resource_group.mynetworks.name
}

resource "azurerm_virtual_network" "myvn" {
  name                = "myvn"
  location            = azurerm_resource_group.mynetworks.location
  resource_group_name = azurerm_resource_group.mynetworks.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.network_security.id
  }
}