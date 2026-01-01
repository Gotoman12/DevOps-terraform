provider "aws" {
    region = "us-east-1" 
}

resource "aws_vpc" "arjun-vpc" {
    cidr_block = "0.0.0.0/16"
    tags = {
      Name = "arjun-vpc" 
    }
}

resource "aws_subnet" "pub1-subnet" {
    cidr_block = "10.1.0.0/24"
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.arjun-vpc.id
  tags = {
    Name = "pub1-subnet"
  }
}
resource "aws_subnet" "pub2-subnet" {
    cidr_block = "10.2.0.0/24"
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.arjun-vpc.id
  tags = {
    Name = "pub2-subnet"
  }
}

resource "aws_route_table" "default_rt" {
vpc_id = aws_vpc.arjun-vpc.id
tags={
    Name="default_rt"
}  
}
resource "aws_internet_gateway" "arjun_ig" {
    vpc_id = aws_vpc.arjun-vpc.id
  tags={
    Name="arjun-ig"
  }
}
resource "aws_route" "route_associate" {
  route_table_id=aws_route_table.default_rt.id
  gateway_id = aws_internet_gateway.arjun_ig.id
  destination_cidr_block="0.0.0.0/0"
}

resource "aws_route_table_association" "sub1-assocaition" {
  route_table_id=aws_route_table.default_rt.id
  subnet_id = aws_subnet.pub1-subnet.id
}
resource "aws_route_table_association" "sub2-assocaition" {
  route_table_id=aws_route_table.default_rt.id
  subnet_id = aws_subnet.pub2-subnet.id
}

#Create a Security Group for an EC2 instance
resource "aws_security_group" "amz-sg" {
    name = "amz-security"
    vpc_id = aws_vpc.arjun-vpc.id
    ingress = {
        protocol = "-1"
        from_port = 0
        to_port = 6000
        cidr_blocks	= ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (restrict in production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }
    egress = {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks	= ["0.0.0.0/0"]
    }

     tags = {
    Name = "App-SG"
  }
}


resource "aws_instance" "master-node" {
    ami = "ami-068c0051b15cdb816"
    instance_type = "t3.small"
    subnet_id = aws_subnet.pub1-subnet
    security_groups = [aws_security_group.amz-sg.id]
    key_name = "ubuntu-key"
    #key_name = "ubuntu-key"
    tags= {
    Name = "terraform-example"
  }

  # Optional: Add user data to install a simple web server on launch
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from Terraform EC2 in a new VPC!</h1>" | sudo tee /var/www/html/index.html
              EOF
}

output "instance-public-ip" {
    value= aws_instance.master-node.public_ip 
}