terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
  backend "s3" {
    bucket         = "tf-remote-s3-bucket-latifs-changehere"
    key            = "env/dev/tf-remote-backend.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-s3-app-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  mytag = "latif-local-name"
}

variable "ec2-type" {
  default = "t2.micro"
}

variable "key-name" {
  default = "latif"
}

data "aws_ami" "tf-ami" {
  most_recent = true
  owners      = ["amazon"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]

  }

}
# data "aws_ami" "latif" { 
#   most_recent      = true 
#   owners           = ["self"]

#   filter {
#     name   = "name"
#     values = ["terraform*"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

resource "aws_instance" "tf-ec2" {
  ami           = data.aws_ami.tf-ami.id
  instance_type = var.ec2-type
  key_name      = var.key-name

  tags = {
    Name = "${local.mytag}-bu Amazon Ami den"
  }
}
resource "aws_s3_bucket" "tf-test-1" {
  bucket = "latif-test-1-versioning"
}

resource "aws_s3_bucket" "tf-test-2" {
  bucket = "latif-test-2-locking-2"
}

output "ami-info" {
  value = data.aws_ami.tf-ami.id

}