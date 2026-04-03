variable "aws_region" {
 description = "region"
 type = string
}

variable "project_name" {
  description = "project"
 type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }

variable "cluster_version" { type = string }
variable "instance_types" { type = list(string) }
variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }

variable "ecr_repo_name" { type = string }

variable "k8s_namespace" { type = string }
variable "app_name" { type = string }
variable "replicas" { type = number }
variable "container_port" { type = number }
variable "image_tag" { type = string }