resource "azurerm_resource_group" "my_resource_group" {
  name     = "my_resource_group"
  location = "West Europe"
}

resource "azurerm_virtual_network" "my_VNET" {
  name                = "my_VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "my_subnet"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_VNET.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "my_NIC" {
  name                = "my_NIC"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.my_VNET,
  ]

}

resource "azurerm_windows_virtual_machine" "my_VM" {
  name                = "myvm"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.my_NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.my_NIC
  ]
}

resource "azurerm_monitor_action_group" "email_alert" {
  name                = "email-alert"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  short_name          = "email"

   email_receiver {
    name                    = "sendtoadmin"
    email_address           = "surangajayalath299@gmail.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "netowrk_threshold_alert" {
  name                = "netowrk_threshold_alert"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  scopes              = [azurerm_windows_virtual_machine.my_VM.id]
  description         = "Action will be triggered when Transactions count is greater than 50."

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network out total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 70

  }
  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
  }

  depends_on = [
    azurerm_monitor_action_group.email_alert,
    azurerm_windows_virtual_machine.my_VM
  ]
}



