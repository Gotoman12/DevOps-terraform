provider "aws" {
  region = "us-east-1"
}

############################
# VPC
############################
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sample-vpc"
  }
}

############################
# Subnets
############################
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

############################
# Internet Gateway & Route Table
############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "route_pt" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "route-pt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.route_pt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "subnet1_assoc" {
  route_table_id = aws_route_table.route_pt.id
  subnet_id      = aws_subnet.subnet1.id
}

resource "aws_route_table_association" "subnet2_assoc" {
  route_table_id = aws_route_table.route_pt.id
  subnet_id      = aws_subnet.subnet2.id
}

############################
# Security Groups
############################
resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = aws_vpc.vpc_1.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

resource "aws_security_group" "eks_worker_node_sg" {
  vpc_id = aws_vpc.vpc_1.id

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
    Name = "eks-worker-node-sg"
  }
}

############################
# IAM Role – EKS Cluster
############################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################
# IAM Role – Worker Nodes
############################
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################
# EKS Cluster
############################
resource "aws_eks_cluster" "project_cluster" {
  name     = "project-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

############################
# EKS Node Group
############################
resource "aws_eks_node_group" "project_node_group" {
  cluster_name    = aws_eks_cluster.project_cluster.name
  node_group_name = "project-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  scaling_config {
    desired_size = 3
    min_size     = 3
    max_size     = 5
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.eks_worker_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy
  ]
}
