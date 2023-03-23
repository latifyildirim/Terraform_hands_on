# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "4.59.0"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"
# }

# resource "aws_instance" "instance" {
#   ami           = "ami-0c02fb55956c7d316"
#   instance_type = "t2.micro"
#   key_name = "latif"
#   security_groups = [ "value" ]

#   provisioner "local-exec" {
#     command = "${self.private_ip}"

#   tags = {
#     Name = "terraform-instance-with-provisioner"
#   }
# }

# resource "aws_security_group" "tf-sec-gr" {
#   name        = "tf-provisioner-sg" 
#   vpc_id      = aws_vpc.main.id

#   ingress { 
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"] 
#   }
#   ingress { 
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"] 
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"] 
#   }

#   tags = {
#     Name = "allow_tls"
#   }
# }

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "instance" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name = "latif"
  security_groups = [ "tf-provisioner-sg" ]

  provisioner "local-exec" {
    command = "echo http://${self.public_ip} >> public_ip.txt"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/latif.pem")
    host     = self.public_ip
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
    destination = "/home/ec2-user/public_ip.txt"
  }

  tags = {
    Name = "terraform-instance-with-provisioner"
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name        = "tf-provisioner-sg"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}