terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1- s3 bucket
resource "aws_s3_bucket" "tf-remote-state" {
  bucket        = "tf-remote-s3-bucket-latifs-changehere"
  force_destroy = true

  tags = {
    Name = "My bucket"
  }
}
# 2- verion
resource "aws_s3_bucket_versioning" "versioning_s3_backend" {
  bucket = aws_s3_bucket.tf-remote-state.id
  versioning_configuration {
    status = "Enabled"
  }
}
# 3- encription  Zaten sifreli geliyor
# 4- dynamodb
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name         = "tf-remote-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}