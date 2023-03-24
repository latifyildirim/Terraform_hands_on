terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance" {
  ami             = "ami-0c02fb55956c7d316"
  instance_type   = "t2.micro"
  key_name        = "latif"
  security_groups = ["provisioner-sg"]

  tags = {
    Name = "Provisioner-ile-yaratildi"
  }
  provisioner "local-exec" {
    command = "echo http://${self.public_ip} >> public_ips.txt"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("~/latif.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
  provisioner "file" {
    content     = self.public_ip
    destination = "/home/ec2-user/public_ips.txt"
  }
}



resource "aws_security_group" "provisioner-sg" {
  name        = "provisioner-sg"
  description = "Allow ssh-http inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh-http"
  }
}