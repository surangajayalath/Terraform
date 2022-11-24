resource "azurerm_resource_group" "vm_rosource_group" {
  name     = "vm_rosource_group"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vm_network" {
  name                = "vm_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rosource_group.location
  resource_group_name = azurerm_resource_group.vm_rosource_group.name
}

resource "azurerm_subnet" "vm_network_subnet" {
  name                 = "vm_network_subnet"
  resource_group_name  = azurerm_resource_group.vm_rosource_group.name
  virtual_network_name = azurerm_virtual_network.vm_network.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [
    azurerm_virtual_network.vm_network
  ]
}

resource "azurerm_network_interface" "vm_network_interface" {
  name                = "vm_network_interface"
  location            = azurerm_resource_group.vm_rosource_group.location
  resource_group_name = azurerm_resource_group.vm_rosource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_network_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.app_public_ip.id
  }
  depends_on = [
    azurerm_virtual_network.vm_network,
    azurerm_public_ip.app_public_ip
  ]
}

# Attach public ip to VM
resource "azurerm_public_ip" "app_public_ip" {
  name                = "app_public_ip"
  resource_group_name = azurerm_resource_group.vm_rosource_group.name
  location            = azurerm_resource_group.vm_rosource_group.location
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "vm_linux" {
  name                = "vm_linux"
  resource_group_name = azurerm_resource_group.vm_rosource_group.name
  location            = azurerm_resource_group.vm_rosource_group.location
  size                = "Standard_F2"
  
  #Add password insted of ssh key
  admin_username      = "linuxuser"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm_network_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.vm_network_interface
  ]
}