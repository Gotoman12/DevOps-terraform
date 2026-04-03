terraform {
  backend "s3" {
    bucket = "arjun-hi52"
    key = "prod/terraform.tfstate"
    encrypt = true
    dynamodb_table = "finance-mlops-tf-lock"
  }
}