variable "db_password" {
  description = "RDS admin password"
  type        = string
  sensitive   = true
  default = "root123456"
}