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
    "Name" = "${var.department}-server"
  }
}

variable "instancetype" {
  description = "Instance type t2.micro"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^[Tt][2-3].(micro|small|medium)", var.instancetype))
    error_message = "Invalid Instance Type name. You can only choose -> t2.micro,t2.small,t2.medium,t3.micro,t3.small,t3.medium"
  }
}

variable "myami" {
  description = "image id for ec2 instance"
  type = string
  default = "ami-022e1a32d3f742bd8"

  validation {
    condition = (
      length(var.myami) > 4 &&
      substr(var.myami, 0, 4) == "ami-"
    )
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "department" {
  description = "department name that owner of the resource"
  type = string
  default = "DEVOPS"

    validation {
      condition = anytrue([
        var.department == "DEVOPS",
        var.department == "FULL_STACK",
        var.department == "DATA_SCIENCE"
      ])
      error_message = "Resource tags must have one of these prefix \"DEVOPS\", \"FULL_STACK\" or \"DATA_SCIENCE\"."
    }


}