provider "aws" {
    region= "us-east-1"  
}

#Creation of vpc
resource "aws_vpc" "project_java" {
    cidr_block = "10.0.0.0/16"

  tags = {
    Name: "project_java"
  }
}

# Subnets (2 public subnets)
resource "aws_subnet" "project_java-subnet-public1" {
  vpc_id = aws_vpc.project_java.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name: "project-java-public-subnet"
  }
}

resource "aws_subnet" "project_java-subnet-public2" {
  vpc_id = aws_vpc.project_java.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name: "project-java-private-subnet"
  }
}

# Route table creation
resource "aws_route_table" "project-java-rt" {
    vpc_id = aws_vpc.project_java.id

    tags = {
      Name: "project-java-rt"
    }
}

# Internet Gateway creation
resource "aws_internet_gateway" "project-java-igw" {
  vpc_id = aws_vpc.project_java.id
  tags = {
    Name: "project-java-igw"
  }
}

# Route 
resource "aws_route" "public_route" {
    route_table_id = aws_route_table.project-java-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-java-igw.id
  
}

#Route Table Association

resource "aws_route_table_association" "public1_association" {
    route_table_id = aws_route_table.project-java-rt.id
    subnet_id = aws_subnet.project_java-subnet-public1.id
}

resource "aws_route_table_association" "public2_association" {
    route_table_id = aws_route_table.project-java-rt.id
    subnet_id = aws_subnet.project_java-subnet-public2.id
}

# EC2 Creation
resource "aws_instance" "my-instance1" {
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t3.small"
    vpc_security_group_ids = ["sg-0e5cd0d51b5f2c17d"]
    count = 3
  
   tags = {
        Name = "Terraform-ec2"
    }
}