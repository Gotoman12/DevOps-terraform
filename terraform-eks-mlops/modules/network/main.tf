module "vpc" {
source  = "terraform-aws-modules/vpc/aws"
version = "6.6.1"
name = var.vpc
cidr = var.vpc_cidr
azs = var.azs

}