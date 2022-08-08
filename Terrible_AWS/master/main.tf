provider "aws" {
  region     = "eu-west-1"
  access_key = file("./access.key")
  secret_key = file("./secret.key")
}

# Creating a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name         = "Mihais' VPC"
    Owner        = "Mihai Losonczi"
    CreatedBy    = "Terraform"
    CreationDate = "04/08/2022"
    Purpose      = "DevOpsInternship"
  }
}

# Creating an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Creating Custom Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  #  route {
  #    ipv6_cidr_block = "::/0"
  #    egress_only_gateway_id = aws_internet_gateway.gw.id
  #  }

  tags = {
    Name         = "Mihais' Route Table"
    Owner        = "Mihai Losonczi"
    CreatedBy    = "Terraform"
    CreationDate = "04/08/2022"
    Purpose      = "DevOpsInternship"
  }
}

# Creating a Subnet
resource "aws_subnet" "internal" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-1a"

  tags = {
    Name         = "Mihais' subnet"
    Owner        = "Mihai Losonczi"
    CreatedBy    = "Terraform"
    CreationDate = "04/08/2022"
    Purpose      = "DevOpsInternship"
  }
}

# Associating subnet with Route Table
resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.internal.id
  route_table_id = aws_route_table.route_table.id
}

# Creating Security Group to allow ports 22 and 80 for webapp
resource "aws_security_group" "webapp_sg" {
  name        = "webapp_security_group"
  description = "Allow traffic on ports 80 and 22"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating Security Group to allow ports 22 and 27017 for mongodb
resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb_security_group"
  description = "Allow traffic on ports 22 and 27017"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    protocol    = "tcp"
    to_port     = 27017
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a network interface for webapp
resource "aws_network_interface" "webapp_ni" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["10.0.2.5"]
  security_groups = [aws_security_group.webapp_sg.id]
}

# Creating a network interface for mongodb
resource "aws_network_interface" "mongodb_ni" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["10.0.2.6"]
  security_groups = [aws_security_group.mongodb_sg.id]
}

# Assigning an elastic IP to the network interface
resource "aws_eip" "webapp_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.webapp_ni.id
  associate_with_private_ip = aws_network_interface.webapp_ni.private_ip
  depends_on                = [aws_internet_gateway.gw]
}

# Assigning an elastic IP to the network interface
resource "aws_eip" "mongodb_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.mongodb_ni.id
  associate_with_private_ip = aws_network_interface.mongodb_ni.private_ip
  depends_on                = [aws_internet_gateway.gw]
}
