# Creating Ubuntu server for webapp
resource "aws_instance" "webapp" {
  ami               = "ami-0d2a4a5d69e46ea0b"
  instance_type     = "t3.nano"
  availability_zone = "eu-west-1a"
  key_name          = "webapp-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.webapp_ni.id
  }

  tags = {
    Name         = "Mihais' webapp"
    Owner        = "Mihai Losonczi"
    CreatedBy    = "Terraform"
    CreationDate = "04/08/2022"
    Purpose      = "DevOpsInternship"
  }

  provisioner "local-exec" {
    command = "bash ./provision/scripts/restore_inventory.sh && sleep 100"
  }

  provisioner "local-exec" {
    command = "sudo sed -i 's/{webapp_ip}/${self.public_ip}'/g ./provision/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ./provision/inventory/inventory ./provision/playbooks/playbook_webapps.yml"
  }

}