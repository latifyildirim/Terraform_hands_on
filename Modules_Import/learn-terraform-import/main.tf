terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "tf-ami" {
  type = list(string)
  default = ["ami-00c39f71452c08778", "ami-0557a15b87f6559cf", "ami-06640050dc3f556bb"]
}

variable "tf-tags" {
  type = list(string)
  default = ["aws-linux", "ubuntu", "red-hat-linux-8", "kalem"]
}

resource "aws_instance" "tf-instances" {
  ami = element(var.tf-ami, count.index )
  instance_type = "t2.micro"
  count = 3
  key_name = "latif"
  security_groups = ["tf-import-sg"]
  tags = {
    Name = element(var.tf-tags, count.index )
  }
}

resource "aws_security_group" "tf-sg" {
  name = "tf-import-sg"
  description = "terraform import security group"
  tags = {
    Name = "tf-import-sg"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}