module "vpc" {
source  = "terraform-aws-modules/vpc/aws"
version = "6.6.1"
name = var.vpc
cidr = var.vpc_cidr
azs = var.azs
public_subnets = var.public_subnets
private_subnets = var.private_subnets

enable_nat_gateway = true
single_nat_gateway = true
}