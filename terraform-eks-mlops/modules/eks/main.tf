module "eks" {
source  = "terraform-aws-modules/eks/aws"
version = "19.21.0"
 cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

vpc_id = var.vpc_id
subnet_ids = var.private_subnets
create_kms_key = false
cluster_encryption_config = []
eks_managed_node_groups = {
    default ={
        instance_types = var.instance_types
        desired_size = var.desired_size
        min_size = var.min_size
        max_size= var.max_size
    }
}
}