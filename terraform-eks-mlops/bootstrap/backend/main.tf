terraform {
  required_version = "~> 1.12"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
    random ={
        source = "hashicorp/random"
        version = "~> 3.0"
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
  source       = "terraform-aws-modules/dynamodb-table/aws"
  version      = "5.5.0"
  name         = "finance-mlops-tf-lock"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}

resource "aws_s3_bucket" "tf_state" {
    bucket = "arjun-${random_string.s3-string.result}"
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}