provider "aws" {
    region = "us-east-1"
}

# vpc creation
resource "aws_vpc" "test-vpc" {
    cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test-vpc"
  }
}

# subnet creation with public and private with availabity zone

resource "aws_subnet" "pubic-sub-1" {
      vpc_id = aws_vpc.test-vpc.id
      cidr_block = "10.0.1.0/24"  
      availability_zone = "us-east-1a"
      map_public_ip_on_launch = true

      tags = {
        Name = "public-sub-1"
      }
}

resource "aws_subnet" "private-sub-1" {
      vpc_id = aws_vpc.test-vpc.id
      cidr_block = "10.0.2.0/24"  
      availability_zone = "us-east-1a"
      map_public_ip_on_launch = true

      tags = {
        Name = "private-sub-1"
      }
}

resource "aws_route_table" "public-route_table" {
    vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "public-route"
  }
}

resource "aws_internet_gateway" "test-igw" {
    vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-igw"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public-route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.test-igw.id
}

resource "aws_route_table_association" "route_association" {
    route_table_id = aws_route_table.public-route_table.id
    subnet_id = aws_subnet.pubic-sub-1.id
}

resource "aws_security_group" "ec2-sg" {
    name = "ec2-sg"
    vpc_id = aws_vpc.test-vpc.id
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "app-sg" {
    name = "app-sg"
    vpc_id = aws_vpc.test-vpc.id
    ingress {
         from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  egress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "app-server" {
    ami = "ami-0b6c6ebed2801a5cb"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.pubic-sub-1.id

    vpc_security_group_ids = [aws_security_group.ec2-sg.id]

    tags = {
      Name = "app=server"
    }
}

resource "aws_instance" "web-server" {
    subnet_id = aws_subnet.private-sub-1.id
    ami = "ami-0b6c6ebed2801a5cb"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.app-sg.id]
    key_name = var.aws_instance
}

resource "aws_db_instance" "mysql" {
    identifier = "mysql"
    engine = "mysql"
    engine_version = "8.0"
    allocated_storage = 20
    instance_class = "db.t4g.micro"
    db_name = "mysqldb"
    username = "admin"
    password = "MySecurePass123!"

skip_final_snapshot = true
publicly_accessible = true
  
}