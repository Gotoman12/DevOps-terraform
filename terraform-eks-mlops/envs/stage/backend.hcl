terraform {
  backend "s3" {
    bucket = "arjun-hi52"
    key = "stage/terraform.tfstate"
    encrypt = true
    dynamodb_table = "finance-mlops-tf-lock"
  }
}