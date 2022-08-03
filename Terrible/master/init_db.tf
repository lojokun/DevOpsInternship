# Creating the db VM
resource "azurerm_virtual_machine" "mongodb" {
  location              = azurerm_resource_group.my_resource_group.location
  name                  = "mongodb"
  network_interface_ids = [
    azurerm_network_interface.mongodb_ni.id,
  ]
  resource_group_name              = azurerm_resource_group.my_resource_group.name
  vm_size                          = "Standard_B1ls"
  zones                            = []
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  os_profile {
    admin_username = "mongodb"
    computer_name  = "mongodb"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = tls_private_key.mongodb_key.public_key_openssh
      path     = "/home/mongodb/.ssh/authorized_keys"
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
    name              = "mongodb_disk"
  }

  tags = {
    Owner        = local.Owner
    CreatedBy    = local.CreatedBy
    CreationDate = local.CreationDate
    Purpose      = local.Purpose
  }

  provisioner "local-exec" {
    command = "sleep 140 && python3 createInventory.py && ansible-playbook ./provision/playbooks/playbook_dbs.yml -i ./provision/inventory/inventory"
  }

}