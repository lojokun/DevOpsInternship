# Creating VM for mongodb
resource "aws_instance" "mongodb" {
  ami               = "ami-0d2a4a5d69e46ea0b"
  instance_type     = "t3.nano"
  availability_zone = "eu-west-1a"
  key_name          = "mongodb-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mongodb_ni.id
  }

  tags = {
    Name         = "Mihais' mongodb"
    Owner        = "Mihai Losonczi"
    CreatedBy    = "Terraform"
    CreationDate = "04/08/2022"
    Purpose      = "DevOpsInternship"
  }

  provisioner "local-exec" {
    command = "bash ./provision/scripts/restore_inventory.sh && sleep 100"
  }

  provisioner "local-exec" {
    command = "sudo sed -i 's/{mongodb_ip}/${self.public_ip}'/g ./provision/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ./provision/inventory/inventory ./provision/playbooks/playbook_dbs.yml"
  }
}