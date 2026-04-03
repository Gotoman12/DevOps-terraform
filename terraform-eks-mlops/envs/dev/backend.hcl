terraform {
  backend "s3" {
    bucket = "arjun-hi52"
    key = "dev/terraform.tfstate"
    encrypt = true
    dynamodb_table = "finance-mlops-tf-lock"
  }
}