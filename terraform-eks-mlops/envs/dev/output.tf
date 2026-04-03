output "cluster_name" { value = module.eks.cluster_name }
output "ecr_url" { value = module.ecr.repository_url }
output "namespace" { value = module.k8s_app.namespace }