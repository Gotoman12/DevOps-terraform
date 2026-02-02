provider "aws" {
  region = "us-east-1"
}

# VPC Creation
resource "aws_vpc" "test-vpc" {
    cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test-vpc"
  }
}

# subnets creation
resource "aws_subnet" "pub-1" {
  vpc_id = aws_vpc.test-vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pub-1"
  }
}

resource "aws_subnet" "pub-2" {
  vpc_id = aws_vpc.test-vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "pub-1"
  }
}

# Route table
resource "aws_route_table" "pub-route" {
    vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "pub-route"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-igw"
  }
}

#Associate IGW to route
resource "aws_route" "route-igw" {
    route_table_id = aws_route_table.pub-route.id
    gateway_id = aws_internet_gateway.test-igw.id
    destination_cidr_block = "0.0.0.0/0"
}

# Associate subnet to route

resource "aws_route_table_association" "sub1-route-association" {
  route_table_id = aws_route_table.pub-route.id
  subnet_id = aws_subnet.pub-1.id
}

resource "aws_route_table_association" "sub2-route-association" {
  route_table_id = aws_route_table.pub-route.id
  subnet_id = aws_subnet.pub-2.id
}

# Worker Node Security Group
resource "aws_security_group" "nodegroup-sg" {
  vpc_id = aws_vpc.test-vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
 tags ={
    Name = "test-node-sg"
 }
}
# Worker Node Cluster Group
resource "aws_security_group" "cluster-sg" {
  vpc_id = aws_vpc.test-vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
 tags ={
    Name = "test-cluster-sg"
 }
}

# IAM Role - EKS Cluster
resource "aws_iam_role" "cluster_role" {
  name = "cluster_role"
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
    role = aws_iam_role.cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role - Node Group role
resource "aws_iam_role" "node_group_role" {
  name = "node_group_role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
      ]
    }
    EOF
}
resource "aws_iam_role_policy_attachment" "node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node_group_role.name
}
resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.itkannadigaru_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  role       = aws_iam_role.itkannadigaru_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS Cluster
resource "aws_eks_cluster" "test_cluster" {
    name = "test_cluster"
    role_arn = aws_iam_role.cluster_role.arn

    vpc_config {
      subnet_ids = [aws_subnet.pub-1.id]
      security_group_ids = [aws_security_group.cluster-sg.id]
    }
  depends_on = [ aws_iam_role_policy_attachment.cluster_policy]
}

# EKS Node Group
resource "aws_eks_node_group" "tes_node" {
    cluster_name = "test_cluster"
    node_group_name = "test_node_group"
    node_role_arn = aws_iam_role.node_group_role.arn
    subnet_ids = aws_subnet.   

    scaling_config {
    desired_size = 3
    max_size     = 50
    min_size     = 3
  }
   instance_types = ["m7i-flex.large"]
}