terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Define the Azure regions
variable "regions" {
  type    = list(string)
  default = ["brazilsouth", "northeurope", "southeastasia", "westus"]
}

# Define the Azure resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = var.regions[0]
}

# Define the Azure Public IP
resource "azurerm_public_ip" "app" {
  count               = length(var.regions)
  name                = "app-${var.regions[count.index]}"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.regions[count.index]
  allocation_method   = "Static"
}

# Define the Azure Network Security Group
resource "azurerm_network_security_group" "app" {
  count               = length(var.regions)
  name                = "app-${var.regions[count.index]}"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.regions[count.index]
  
  security_rule {
    name                       = "app"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1099"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Define the Azure Network Interface
resource "azurerm_network_interface" "app" {
  count               = length(var.regions)
  name                = "app-nic-${var.regions[count.index]}"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.regions[count.index]

  ip_configuration {
    name                          = "app-ip"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.example[count.index].id
    public_ip_address_id          = azurerm_public_ip.app[count.index].id
  }
}

# Define the Azure Virtual Machine
resource "azurerm_virtual_machine" "exampleVM" {
  count                 = length(var.regions)
  name                  = "example-vm-${var.regions[count.index]}"
  location              = var.regions[count.index]
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.app[count.index].id]

  vm_size              = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "Password1234!"  # Change this to a strong password

    #custom_data = base64encode("")

    #linux_configuration {
    #  disable_password_authentication = false

    #  ssh_keys {
    #    path     = "/home/adminuser/.ssh/authorized_keys"
    #    key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZs2u5eE1NJKECLYDXYNbhJ7vL9LQxtFca9x8VisqdtfHo+EHVIMiz1YfyW2OHAL6QpRQ+JiLcfJIY8H4pZkOTCUOa0KYP/nCzPWocSUVwg/2SaAuatlEm/4t8bXXbz6bxxnrzZsGvk0ctGl4lakSsg3pV1WPLStRZvpVYbwKXNQr+fCURvoLcYiJ5ujfOalUsAWXK/nusYW3bmmn486yV4AnkS6FhFTuLYn4r19tQdg9JyYjLgFTZGfvIq3L00L0nBnzK9SG3ZikDRZCRezzyT4nVEOJqwjWm5k1nupryScLq0arqsFUS04ahycJo21AnGJkdABHfEXsK4D1m36BviQZdxdg9adyOog7Op7tB207t24bRYNv3ZPbjcUHX6kS7pzv/P5NJw+BFYc7a0NpYwPGt+WmZvdkTsd2Is5CROtm3txYsvLW2V5Ny276QN5bwoCQEGsRKh7ovl1jz2FqgxW7WT8mD1pyjLtBOyont81Chc8s8u6Tj1NFQ/mafe8U= adrian@adrian-GL753VD"
    #  }
    #}
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
        path     = "/home/adminuser/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZs2u5eE1NJKECLYDXYNbhJ7vL9LQxtFca9x8VisqdtfHo+EHVIMiz1YfyW2OHAL6QpRQ+JiLcfJIY8H4pZkOTCUOa0KYP/nCzPWocSUVwg/2SaAuatlEm/4t8bXXbz6bxxnrzZsGvk0ctGl4lakSsg3pV1WPLStRZvpVYbwKXNQr+fCURvoLcYiJ5ujfOalUsAWXK/nusYW3bmmn486yV4AnkS6FhFTuLYn4r19tQdg9JyYjLgFTZGfvIq3L00L0nBnzK9SG3ZikDRZCRezzyT4nVEOJqwjWm5k1nupryScLq0arqsFUS04ahycJo21AnGJkdABHfEXsK4D1m36BviQZdxdg9adyOog7Op7tB207t24bRYNv3ZPbjcUHX6kS7pzv/P5NJw+BFYc7a0NpYwPGt+WmZvdkTsd2Is5CROtm3txYsvLW2V5Ny276QN5bwoCQEGsRKh7ovl1jz2FqgxW7WT8mD1pyjLtBOyont81Chc8s8u6Tj1NFQ/mafe8U= adrian@adrian-GL753VD"
    }
  }

  storage_os_disk {
    name              = "osdisk-${var.regions[count.index]}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

# Define the Azure Subnet
resource "azurerm_subnet" "example" {
  count               = length(var.regions)
  name                = "example-subnet-${var.regions[count.index]}"
  resource_group_name = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example[count.index].name
  address_prefixes    = ["10.0.0.0/16"]
}

# Define the Azure Virtual Network
resource "azurerm_virtual_network" "example" {
  count               = length(var.regions)
  name                = "example-vnet-${var.regions[count.index]}"
  address_space       = ["10.0.0.0/16"]
  location            = var.regions[count.index]
  resource_group_name = azurerm_resource_group.example.name
}

