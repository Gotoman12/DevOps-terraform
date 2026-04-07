output "cluster_endpoint" {
  value = module.eks.cluster_name
}

output "ecr_url" {
  value = module.ecr.repository_url
}

