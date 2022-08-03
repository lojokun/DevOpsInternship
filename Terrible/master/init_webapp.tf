# Creating a Virtual Machine
resource "azurerm_virtual_machine" "webapp" {
  location              = azurerm_resource_group.my_resource_group.location
  name                  = "webapp"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  resource_group_name              = azurerm_resource_group.my_resource_group.name
  tags                             = {}
  vm_size                          = "Standard_B1ls"
  zones                            = []
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

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

  provisioner "local-exec" {
    command = "./provision/scripts/restore_inventory.sh && sed -i 's/{host}/${azurerm_public_ip.webapp_ip.ip_address}/g' ./provision/inventory/inventory"
  }
#  provisioner "local-exec" {
#    command = ""
#  }
  provisioner "local-exec" {
    command = "./provision/scripts/copy_sshkey.sh"
  }
  provisioner "local-exec" {
    command = "ansible-playbook ./provision/playbooks/playbook_webapps.yml -i ./provision/inventory/inventory"
  }

}