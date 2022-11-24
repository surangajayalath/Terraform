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
    public_ip_address_id          = azurerm_public_ip.app_public_ip.id
  }

  depends_on = [
    azurerm_virtual_network.my_VNET,
    azurerm_public_ip.app_public_ip
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

resource "azurerm_log_analytics_workspace" "vm_workspace" {
  name                = "vmworkspace1992"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_machine_extension" "vm_agent" {

  name                 = "vmagent"
  virtual_machine_id   = azurerm_windows_virtual_machine.my_VM.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  
  auto_upgrade_minor_version = "true"
  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.vm_workspace.workspace_id}"
    }
SETTINGS
   protected_settings = <<PROTECTED_SETTINGS
   {
      "workspaceKey": "${azurerm_log_analytics_workspace.vm_workspace.primary_shared_key}"
   }
PROTECTED_SETTINGS
}

resource "azurerm_log_analytics_datasource_windows_event" "collect_events" {
  name                = "collect-events"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  workspace_name      = azurerm_log_analytics_workspace.vm_workspace.name
  event_log_name      = "Application"
  event_types         = ["Error"]
}