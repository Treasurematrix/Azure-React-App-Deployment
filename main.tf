provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "react-app-rg" {
  name     = "react-app-rg"
  location = "canadacentral"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "react-app-vnet" {
  name                = "react-app-vnet-network"
  resource_group_name = azurerm_resource_group.react-app-rg.name
  location            = azurerm_resource_group.react-app-rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "react-app-subnet" {
  name                 = "react-app-subnet"
  resource_group_name  = azurerm_resource_group.react-app-rg.name
  virtual_network_name = azurerm_virtual_network.react-app-vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

# Create a network security group within the resource group

resource "azurerm_network_security_group" "react-app-nsg" {
  name                = "react-app-nsg"
  location            = azurerm_resource_group.react-app-rg.location
  resource_group_name = azurerm_resource_group.react-app-rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# create a public IP address for the virtual machine
resource "azurerm_public_ip" "ReactAppPublicIp" {
  name                = "ReactAppPublicIp"
  resource_group_name = azurerm_resource_group.react-app-rg.name
  location            = azurerm_resource_group.react-app-rg.location
  allocation_method   = "Static"


}

# Create a network interface within the subnet
resource "azurerm_network_interface" "ReactAppNic" {
  name                = "ReactAppNic"
  location            = azurerm_resource_group.react-app-rg.location
  resource_group_name = azurerm_resource_group.react-app-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.react-app-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ReactAppPublicIp.id

  }
}

# create a network interface security group association
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.ReactAppNic.id
  network_security_group_id = azurerm_network_security_group.react-app-nsg.id
}

# Create a Linux virtual machine within the resource group and associate it with the network interface
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "react-app-vm"
  resource_group_name = azurerm_resource_group.react-app-rg.name
  location            = azurerm_resource_group.react-app-rg.location
  size                = "Standard_B2as_v2"
  admin_username      = "chiomanwosu"
  network_interface_ids = [
    azurerm_network_interface.ReactAppNic.id,
  ]

  admin_password                  = "ChiomaDMI@azure"
  disable_password_authentication = false


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

output "public_ip" {
  value = azurerm_public_ip.ReactAppPublicIp.ip_address
}