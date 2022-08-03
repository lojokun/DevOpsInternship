#!/bin/bash
terraform apply -target=azurerm_virtual_network.vnet1 -target=azurerm_network_security_group.ports -target=azurerm_subnet.internal -target=azurerm_subnet_network_security_group_association.subnet_ports -target=azurerm_network_interface.main -target=tls_private_key.linux_key -target=local_file.linux_key_local -target=azurerm_public_ip.webapp_ip -auto-approve
terraform apply -target=resource.azurerm_virtual_machine.webapp -auto-approve
