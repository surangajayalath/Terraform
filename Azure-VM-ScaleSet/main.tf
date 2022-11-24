resource "azurerm_resource_group" "app_grp" {
  name     = "LoadBalancerRG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.app_grp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}


# The public IP for load balancer
resource "azurerm_public_ip" "app_public_ip" {
  name                = "LB-IP"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "app_balacer" {
  name                = "LoadBalancer"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.app_public_ip.id
  }

  depends_on = [
    azurerm_public_ip.app_public_ip
  ]
}

# define backend pool
resource "azurerm_lb_backend_address_pool" "scaleset_pool" {
  loadbalancer_id = azurerm_lb.app_balacer.id
  name            = "scalesetPool"
  depends_on = [
    azurerm_lb.app_balacer
  ]
}


resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.app_balacer.id
  name            = "ssh-running-probe"
  port            = 22
  protocol        = "Tcp"
  depends_on = [
    azurerm_lb.app_balacer
  ]
}
resource "azurerm_lb_rule" "rule" {
  loadbalancer_id                = azurerm_lb.app_balacer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [ azurerm_lb_backend_address_pool.scaleset_pool.id]
}

resource "azurerm_windows_virtual_machine_scale_set" "scale_set" {
  name                = "scale_Set"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  sku                 = "Standard_D2s_v3"
  instances           = 2
  admin_password      = "Azure@1234"
  admin_username      = "myadmin"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "scaleset-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.app_subnet.id
      load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.scaleset_pool.id]
    }
  }
  depends_on = [
    azurerm_virtual_network.app_network
  ]
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
  name                   = "IIS_COnfig.ps1"
  storage_account_name   = azurerm_storage_account.storage_Account.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "IIS_COnfig.ps1"
  depends_on = [
    azurerm_storage_container.data
  ]
}


resource "azurerm_virtual_machine_scale_set_extension" "scaleset_ext" {
  name                         = "scaleset_ext"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.scale_set.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  depends_on = [
    azurerm_storage_blob.sample
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.storage_Account.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS
}

# Create security group
resource "azurerm_network_security_group" "sec-grp" {
  name                = "sec-grp"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

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
  subnet_id = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.sec-grp.id
  depends_on = [
    azurerm_network_security_group.sec-grp
  ]
}
