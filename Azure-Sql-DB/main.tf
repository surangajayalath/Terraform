resource "azurerm_resource_group" "db-rsc" {
  name     = "db-src"
  location = "West Europe"
}

resource "azurerm_sql_server" "sql_server" {
  name                         = "sql_server"
  resource_group_name          = azurerm_resource_group.db-src.name
  location                     = azurerm_resource_group.db-src.location
  version                      = "12.0"
  administrator_login          = "myadmin"
  administrator_login_password = "Azure@1234"
}

resource "azurerm_sql_database" "sql_db" {
  name                = "sql_db"
  resource_group_name = azurerm_resource_group.db-rsc.name
  location            = azurerm_resource_group.db-rsc.location
  server_name         = azurerm_sql_server.sql_server.name

  depends_on = [
    azurerm_sql_server.sql_server
  ]

}

# For access through internet
resource "azurerm_sql_firewall_rule" "sql_firewall_rule" {
  name                = "sql_firewall_rule"
  resource_group_name = azurerm_resource_group.db-rsc.name
  server_name         = azurerm_sql_server.sql_server.name
  start_ip_address    = "175.157.40.69" # my ip
  end_ip_address      = "175.157.40.69" # my ip

  depends_on = [
    azurerm_sql_server.sql_server
  ]
}