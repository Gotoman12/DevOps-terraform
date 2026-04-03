aws_region      = "ap-south-1"
project_name    = "finance-mlops"
environment     = "dev"

vpc_cidr        = "10.10.0.0/16"
azs             = ["ap-south-1a", "ap-south-1b"]
private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]

cluster_version = "1.29"
instance_types  = ["t3.small"]
desired_size    = 2
min_size        = 2
max_size        = 4

ecr_repo_name   = "finance-ml-api"

k8s_namespace   = "mlops"
app_name        = "ml-api"
replicas        = 2
container_port  = 8000
image_tag       = "latest"

