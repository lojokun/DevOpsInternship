terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# terraform import azurerm_resource_group.my_resource_group /subscriptions/7c832c08-fc53-42ba-b6b0-eb70d764f271/resourceGroups/rg-devopsint-mihai_losonczi

resource "azurerm_resource_group" "my_resource_group" {
  name     = local.RG_name
  location = "West Europe"
  tags     = {
    Owner        = local.Owner,
    Purpose      = local.Purpose,
    CreationDate = "27/07/2022",
    CreatedBy    = local.CreatedBy
  }
}

# Creating a Virtual Network
resource "azurerm_virtual_network" "vnet1" {
  name                = local.VNet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  tags                = {
    Purpose      = local.Purpose
    CreationDate = local.CreationDate
    CreatedBy    = local.CreatedBy
    Owner        = local.Owner
  }
}
# Creating a Security Group
resource "azurerm_network_security_group" "ports" {
  location            = azurerm_resource_group.my_resource_group.location
  name                = "webapp-nsg"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  security_rule       = [
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "22"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "SSH"
      priority                                   = 300
      protocol                                   = "Tcp"
      source_address_prefix                      = "*"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    },
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "80"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "HTTP"
      priority                                   = 320
      protocol                                   = "Tcp"
      source_address_prefix                      = "*"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    },
  ]
  tags = {}

  timeouts {}
}
# Creating a Subnet Mask
resource "azurerm_subnet" "internal" {
  name                 = local.Subnet_name
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Creating link between subnet and security group
resource "azurerm_subnet_network_security_group_association" "subnet_ports" {

  network_security_group_id = azurerm_network_security_group.ports.id
  subnet_id                 = azurerm_subnet.internal.id
}

# Creating Network Interface
resource "azurerm_network_interface" "main" {
  enable_accelerated_networking = false
  enable_ip_forwarding          = false
  location                      = "westeurope"
  name                          = "webapp638"
  resource_group_name           = "rg-devopsint-mihai_losonczi"
  tags                          = {}

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "10.0.2.5"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.webapp_ip.id
    subnet_id                     = azurerm_subnet.internal.id
  }

  timeouts {}
}

# Creating a TLS Private Key
resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linux_key_local" {
  filename = "linuxkey.pem"
  content  = tls_private_key.linux_key.private_key_pem
}

resource "azurerm_public_ip" "webapp_ip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  allocation_method   = "Dynamic"

  tags = {
    Owner = local.Owner
  }
}

# Creating a Virtual Machine
resource "azurerm_virtual_machine" "webapp" {
  location              = azurerm_resource_group.my_resource_group.location
  name                  = "webapp"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  resource_group_name = azurerm_resource_group.my_resource_group.name
  tags                = {}
  vm_size             = "Standard_B1ls"
  zones               = []
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  os_profile {
    admin_username = "webapp"
    computer_name  = "webapp"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = tls_private_key.linux_key.public_key_openssh
      path     = "/home/webapp/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = 30
    managed_disk_type = "Standard_LRS"
    os_type           = "Linux"
    name              = "webapp_disk"
  }

  timeouts {}
}