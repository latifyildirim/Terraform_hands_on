terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "tf-ec2" {
  ami           = var.myami
  instance_type = var.instancetype
  tags = {
    "Name" = "created-by-tf"
  }
}

variable "instancetype" {
  description = "Instance type t2.micro"
  type        = string
  default     = "t2.micro"
}

variable "myami" {
  description = "image id for amazon linux 2023"
  type = string
  default = "ami-022e1a32d3f742bd8"
}