terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.38.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"
}

module "network" {
  source          = "../../modules/network"
  name             = "${var.project_name}-${var.environment}-vpc"
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "${var.project_name}-${var.environment}-eks"
  cluster_version = var.cluster_version
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets

  instance_types = var.instance_types
  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  
}

module "ecr" {
  source    = "../../modules/ecr"
  repository_name = var.ecr_repo_name
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

   depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

   depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "k8s_app" {
  source         = "../../modules/k8s-app"
  namespace      = var.k8s_namespace
  app_name       = var.app_name
  replicas       = var.replicas
  container_port = var.container_port
  image_repo     = module.ecr.repository_url
  image_tag      = var.image_tag

  depends_on = [module.eks]
}