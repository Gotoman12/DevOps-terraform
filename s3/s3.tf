provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "arjun23_bucket"
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = true
  }
}

resource "aws_s3_object" "s3_object" {
  bucket = aws_s3_bucket.s3_bucket.id
  key = "config/app.properties"
  source = "local/app.properties"
}