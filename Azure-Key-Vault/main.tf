resource "azurerm_resource_group" "my_resource_group" {
  name     = "my_resource_group"
  location = "West Europe"
}
# For azure eku vault
data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "my_VNET" {
  name                = "my_VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  depends_on = [
    azurerm_resource_group.my_resource_group
  ]
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
    azurerm_public_ip.app_public_ip,
    azurerm_subnet.my_subnet
  ]

}

resource "azurerm_windows_virtual_machine" "my_VM" {
  name                = "myvm"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"

# Add key valut here
  admin_password      = azurerm_key_vault_secret.vmpassword.value
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
    azurerm_network_interface.my_NIC,
    azurerm_key_vault_secret.vmpassword
  ]
}

# Attach public ip to VM
resource "azurerm_public_ip" "app_public_ip" {
  name                = "app_public_ip"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  allocation_method   = "Static"
}

resource "azurerm_key_vault" "app_vault" {
  name                        = "appvault"
  location                    = azurerm_resource_group.my_resource_group.location
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

# First letter should be capitalized
    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

# Creating a secret in the key valut
resource "azurerm_key_vault_secret" "vmpassword" {
  name = "vmpassword"
  value = "Azure@1234"
  key_vault_id = azurerm_key_vault.app_vault.id
  depends_on = [
    azurerm_key_vault.app_vault
  ]
}