# --- GROUPE DE RESSOURCES ---
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.app_name}"
  location = var.region
}

# --- RESEAU --- 
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.app_name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.app_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "ip-${var.app_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# --- NSG (SECURITÉ) ---
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.app_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    #trivy:ignore:AVD-AZU-0047
  }

  # SSH : ON OUVRE LES DEUX PORTS (SEULE FAÇON DE DÉBLOQUER)
  security_rule {
    name                       = "Allow-SSH-Dual"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "2222"] 
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    #trivy:ignore:AVD-AZU-0050 #trivy:ignore:AVD-AZU-0047
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.app_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# --- VM (SANS SCRIPT CUSTOM_DATA) ---
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.app_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.instance_size
  admin_username      = var.admin_user
  network_interface_ids = [ azurerm_network_interface.nic.id ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}