provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "arjun_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "arjun-vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "pub1_subnet" {
  vpc_id                  = aws_vpc.arjun_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "pub1-subnet"
  }
}

# Public Subnet 2
resource "aws_subnet" "pub2_subnet" {
  vpc_id                  = aws_vpc.arjun_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "pub2-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "arjun_ig" {
  vpc_id = aws_vpc.arjun_vpc.id

  tags = {
    Name = "arjun-ig"
  }
}

# Route Table
resource "aws_route_table" "default_rt" {
  vpc_id = aws_vpc.arjun_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arjun_ig.id
  }

  tags = {
    Name = "default-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "sub1_assoc" {
  subnet_id      = aws_subnet.pub1_subnet.id
  route_table_id = aws_route_table.default_rt.id
}

resource "aws_route_table_association" "sub2_assoc" {
  subnet_id      = aws_subnet.pub2_subnet.id
  route_table_id = aws_route_table.default_rt.id
}

# Security Group
resource "aws_security_group" "amz_sg" {
  name   = "amz-security"
  vpc_id = aws_vpc.arjun_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-SG"
  }
}

# EC2 Instance
resource "aws_instance" "master_node" {
  ami                         = "ami-068c0051b15cdb816"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.pub1_subnet.id
  vpc_security_group_ids      = [aws_security_group.amz_sg.id]
  key_name                    = "ubuntu-key"
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from Terraform EC2 in a new VPC!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "terraform-example"
  }
}

# Output
output "instance_public_ip" {
  value = aws_instance.master_node.public_ip
}
