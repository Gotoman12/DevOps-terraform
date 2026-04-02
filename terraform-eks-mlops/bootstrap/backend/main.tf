terraform {
  required_version = "~> 1.12"
  required_providers {
    aws = {
        source = "hashicrop/aws"
        version = "~> 6.0"
    }
    random ={
        source = "hashicrop/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
resource "random_string" "s3-string" {
  length = 4
  special = false
  lower = true
  upper = false
}


module "dynamodb-table" {
source  = "terraform-aws-modules/dynamodb-table/aws"
version = "5.5.0"
name = "finance-mlops-tf-lock"
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockId"

attributes = {
    name = "LockId"
    type = "S"
  }
}

resource "aws_s3_bucket" "s3-bucket" {
    bucket = "arjun-${random_string.s3-string.result}"
}
