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
  name                = "environment-nsg"
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
      destination_address_prefix                 = "10.0.2.5"
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
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "10.0.2.6"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "27017"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "MongoDB"
      priority                                   = 340
      protocol                                   = "Tcp"
      source_address_prefix                      = "10.0.2.5"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    },
  ]
  tags = {
    Owner        = local.Owner
    CreatedBy    = local.CreatedBy
    CreationDate = local.CreationDate
    Purpose      = local.Purpose
  }
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

# Creating the Network Interface for webapp VM
resource "azurerm_network_interface" "webapp_ni" {
  enable_accelerated_networking = false
  enable_ip_forwarding          = false
  location                      = azurerm_resource_group.my_resource_group.location
  name                          = "webapp_ni"
  resource_group_name           = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "10.0.2.5"
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.webapp_ip.id
    subnet_id                     = azurerm_subnet.internal.id
  }

  tags = {
    Owner        = local.Owner
    CreatedBy    = local.CreatedBy
    CreationDate = local.CreationDate
    Purpose      = local.Purpose
  }
}
# Creating the Network Interface for mongodb VM
resource "azurerm_network_interface" "mongodb_ni" {
  enable_accelerated_networking = false
  enable_ip_forwarding          = false
  location                      = azurerm_resource_group.my_resource_group.location
  name                          = "mongodb_ni"
  resource_group_name           = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "10.0.2.6"
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.mongodb_ip.id
    subnet_id                     = azurerm_subnet.internal.id
  }

  tags = {
    Owner        = local.Owner
    CreatedBy    = local.CreatedBy
    CreationDate = local.CreationDate
    Purpose      = local.Purpose
  }
}

# Creating a TLS Private Key for webapp VM
resource "tls_private_key" "webapp_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Storing the private key locally
resource "local_file" "webapp_key_local" {
  filename = "webapp_key.pem"
  content  = tls_private_key.webapp_key.private_key_pem
  provisioner "local-exec" {
    command = "cp ./webapp_key.pem /home/vagrant/.ssh/webapp_key.pem"
  }
}
# Creating a TLS Private Key for mongodb VM
resource "tls_private_key" "mongodb_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Storing the private key locally
resource "local_file" "mongodb_local" {
  filename = "mongodb_key.pem"
  content  = tls_private_key.mongodb_key.private_key_pem
  provisioner "local-exec" {
    command = "cp ./mongodb_key.pem /home/vagrant/.ssh/mongodb_key.pem"
  }
}

# Creating a Public IP resource
resource "azurerm_public_ip" "webapp_ip" {
  name                = "webapp_PublicIp"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  allocation_method   = "Dynamic"

  tags = {
    Owner        = local.Owner
    CreatedBy    = local.CreatedBy
    CreationDate = local.CreationDate
    Purpose      = local.Purpose
  }

}
resource "azurerm_public_ip" "mongodb_ip" {
  name                = "mongodb_PublicIp"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = azurerm_resource_group.my_resource_group.location
  allocation_method   = "Dynamic"

  tags = {
    Owner        = local.Owner
    CreatedBy    = local.CreatedBy
    CreationDate = local.CreationDate
    Purpose      = local.Purpose
  }

}
