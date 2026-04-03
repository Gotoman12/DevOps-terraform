variable "namespace" { type = string }
variable "app_name" { type = string }
variable "replicas" { type = number }
variable "container_port" { type = number }
variable "image_repo" { type = string }
variable "image_tag" { type = string }