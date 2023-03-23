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

locals {
  mytag = "latif-local-name"
}

resource "aws_instance" "tf-ec2" {
  ami           = var.ec2-ami
  instance_type = var.ec2-type
  key_name      = var.key_name

  tags = {
    Name = "${local.mytag}-come from locals"
  }
} 

resource "aws_s3_bucket" "tf-s3" {
#   bucket = "${var.s3_bucket_name}-${count.index}"
#   count  = var.num_of_buckets
#   count = var.num_of_buckets != 0 ? var.num_of_buckets : 3
  for_each = toset(var.users)
  bucket   = "example-tf-s3-bucket-${each.value}"
}

resource "aws_iam_user" "new-users" {
  for_each = toset(var.users)
  name = each.value
}