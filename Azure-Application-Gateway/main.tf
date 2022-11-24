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
  depends_on = [
    azurerm_resource_group.mynetworks
  ]
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "subnet_1"
  resource_group_name  = azurerm_resource_group.mynetworks.name
  virtual_network_name = azurerm_virtual_network.myvn.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.myvn
  ]
}

resource "azurerm_subnet" "subnet_2" {
  name                 = "subnet_2"
  resource_group_name  = azurerm_resource_group.mynetworks.name
  virtual_network_name = azurerm_virtual_network.myvn.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.myvn
  ]
}

resource "azurerm_network_interface" "network_interface" {
  name                = "network_interface"
  location            = azurerm_resource_group.mynetworks.location
  resource_group_name = azurerm_resource_group.mynetworks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"

  }
  depends_on = [
    azurerm_virtual_network.myvn,
    azurerm_subnet.subnet_1
  ]
}

resource "azurerm_network_interface" "network_interface2" {
  name                = "network_interface2"
  location            = azurerm_resource_group.mynetworks.location
  resource_group_name = azurerm_resource_group.mynetworks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"

  }
  depends_on = [
    azurerm_virtual_network.myvn,
    azurerm_subnet.subnet_1
  ]
}

resource "azurerm_windows_virtual_machine" "my_VM1" {
  name                = "myvm1"
  resource_group_name = azurerm_resource_group.mynetworks.name
  location            = azurerm_resource_group.mynetworks.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.network_interface.id
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
    azurerm_network_interface.network_interface
  ]
}

resource "azurerm_windows_virtual_machine" "my_VM2" {
  name                = "myvm2"
  resource_group_name = azurerm_resource_group.mynetworks.name
  location            = azurerm_resource_group.mynetworks.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.network_interface2.id
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
    azurerm_network_interface.network_interface2
  ]
}

resource "azurerm_storage_account" "storage_Account" {
  name                     = "mystorageaccount19970727"
  resource_group_name      = "app-grp"
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"


}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage_Account.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.storage_Account
  ]
}

# This is used to upload a local file onto the container
resource "azurerm_storage_blob" "IIS_config_video" {
  name                   = "IIS_config_video.ps1"
  storage_account_name   = azurerm_storage_account.storage_Account.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "IIS_config_video.ps1"
  depends_on = [
    azurerm_storage_container.data
  ]
}

resource "azurerm_storage_blob" "IIS_config_image" {
  name                   = "IIS_config_image.ps1"
  storage_account_name   = azurerm_storage_account.storage_Account.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "IIS_config_image.ps1"
  depends_on = [
    azurerm_storage_container.data
  ]
}

resource "azurerm_virtual_machine_extension" "vm_extension1" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.my_VM1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config_video
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.storage_Account.name}.blob.core.windows.net/data/IIS_Config_video.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_video.ps1"     
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "vm_extension2" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.my_VM2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config_video
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.storage_Account.name}.blob.core.windows.net/data/IIS_Config_video.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_video.ps1"     
    }
SETTINGS
}

# Create security group
resource "azurerm_network_security_group" "sec-grp" {
  name                = "sec-grp"
  location            = azurerm_resource_group.mynetworks.location
  resource_group_name = azurerm_resource_group.mynetworks.name

# For HTTP traffic
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "sg-asso" {
  subnet_id = azurerm_subnet.subnet_1.id
  network_security_group_id = azurerm_network_security_group.sec-grp.id
  depends_on = [
    azurerm_network_security_group.sec-grp
  ]
}

# Public ip for gateway
resource "azurerm_public_ip" "gateway_ip" {
  name                = "gateway-ip"
  resource_group_name = azurerm_resource_group.mynetworks.name
  location            = azurerm_resource_group.mynetworks.location
  allocation_method   = "Dynamic"
  
}

resource "azurerm_application_gateway" "app_gatway" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.mynetworks.name
  location            = azurerm_resource_group.mynetworks.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet_2.id
  }
  
  frontend_port {
    name = "frontend_port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend_ip_configuration"
    public_ip_address_id = azurerm_public_ip.gateway_ip.id
  }

   backend_address_pool {
    name = "videopool"
    ip_addresses = [
        "${azurerm_network_interface.network_interface.private_ip_address}"
    ]
  }

  backend_address_pool {
    name = "imagepool"
    ip_addresses = [
        "${azurerm_network_interface.network_interface2.private_ip_address}"
    ]
  }

  backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "gateway_listener"
    frontend_ip_configuration_name = "frontend_ip_configuration"
    frontend_port_name             = "frontend_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "RoutingRule1"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "gateway_listener"
    url_path_map_name          = "RoutingPath"

  }

  url_path_map {
    name                               = "RoutingPath"    
    default_backend_address_pool_name   = "videopool"
    default_backend_http_settings_name  = "HTTPSetting"

     path_rule {
      name                          = "VideoRoutingRule"
      backend_address_pool_name     = "videopool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/videos/*",
      ]
    }

    path_rule {
      name                          = "ImageRoutingRule"
      backend_address_pool_name     = "imagepool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/images/*",
      ]
    }
  }
}