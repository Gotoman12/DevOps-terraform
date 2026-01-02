# Input variable: S3 bucket name
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "terraform-state-my-bucket"
}