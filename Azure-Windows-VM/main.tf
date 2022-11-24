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

# Attach public ip to VM
resource "azurerm_public_ip" "app_public_ip" {
  name                = "app_public_ip"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  allocation_method   = "Static"
}

# Create data disk 
resource "azurerm_managed_disk" "my_disk" {
  name                 = "my_disk"
  location             = azurerm_resource_group.my_resource_group.location
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16
}

# Attach the created data disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.my_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.my_VM.id
  lun                = "0" # logical unit number
  caching            = "ReadWrite"

  depends_on = [
    azurerm_windows_virtual_machine.my_VM,
    azurerm_managed_disk.my_disk
  ]
}