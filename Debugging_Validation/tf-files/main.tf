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

locals {
  user = "oliver"
  instance = "t2.micro"
  mypem = "oliver"
}

data "aws_ami" "amazon_linux2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "elk" {
  ami = data.aws_ami.amazon_linux2.id
  instance_type = local.instance
  key_name = local.mypem
  vpc_security_group_ids = [aws_security_group.elk-sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  tags = {
    Name = "terraform-server-${local.user}"
  }
  user_data = file("userdata.sh")
}

resource "aws_iam_role" "aws_access" {
  name = "awsrole-terraform-${local.user}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]

}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "terraform-profile-${local.user}"
  role = aws_iam_role.aws_access.name
}


resource "aws_security_group" "elk-sg" {
  name = "terraform-sec-gr-${local.user}"
  tags = {
    Name = "terraform-sec-gr-${local.user}"
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}