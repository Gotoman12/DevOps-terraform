module "eks" {
source  = "terraform-aws-modules/eks/aws"
version = "20.13.1"
 cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

vpc_id = module.vpc_id
subnet_ids = var.private_subnets

eks_managed_node_groups = {
    default ={
        instance_types = var.instance_types
        desired_size = var.desired_size
        min_size = var.min_size
        max_size= var.max_size
    }
}
}