# Hands-on Terraform-06 :Debugging Terraform:

Purpose of the this hands-on training is to give students the knowledge of debugging in Terraform.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Debugging Terraform

- Terraform Validation

## Outline

- Part 1 - Debugging Terraform Terraform

- Part 2 - Terraform Validation

## Create an EC2 instance with installed terraform

- Launch an EC2 instance (`Amazon Linux 2023 AMI with security group allowing SSH connections, installed terraform and attach "AmazonEC2FullAccess" policy`) using the terraform files in your github repository.

- Connect to your instance with SSH.

```bash
ssh -i .ssh/clarusway.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

- Verify that the installations.

```bash
terraform --version
```

## Part 1 - Debugging Terraform

- Terraform has detailed logs that you can enable by setting the ``TF_LOG`` environment variable to any value. Enabling this setting causes detailed logs to appear on stderr.

- You can set TF_LOG to one of the log levels (in order of decreasing verbosity) ``TRACE``, ``DEBUG``, ``INFO``, ``WARN`` or ``ERROR`` to change the verbosity of the logs.

- Logging can be enabled separately for terraform itself and the provider plugins using the ``TF_LOG_CORE`` or ``TF_LOG_PROVIDER`` environment variables. These take the same level arguments as TF_LOG, but only activate a subset of the logs.

- To persist logged output you can set ``TF_LOG_PATH`` in order to force the log to always be appended to a specific file when logging is enabled. Note that even when TF_LOG_PATH is set, TF_LOG must be set in order for any logging to be enabled.

- Create a folder to run terraform configuration file.

```bash
mkdir tf-log && cd tf-log && touch log.tf
```

- Run the following commands.

```bash
export TF_LOG=TRACE
export TF_LOG_PATH=./debug.log
```

- ``TRACE`` provides the highest level of logging and contains all the information the development teams need.

- Create a file named `log.tf` for the configuration code and copy and paste the following content. 

```go
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
```

- Make a syntax error (ex: delete a character from an argument) and run the following commands.

```bash
terraform init
terraform apply
# correct the error and run terraform again.
terraform apply
```

- After running terraform files, a new will be created name `debug.log`.

- Now, inspect the `debug.log` file. It contains terraform logs.

- Next, destroy the infrastructure.

```bash
terraform destroy --auto-approve
```

## Part 2 - Terraform Validation

- Although the syntax and configuration of your Terraform may be valid, the variables passed into your configuration may not be valid. Passing invalid variables generally results in errors during the deployment stage. Using the Terraform variable validation function can help you avoid errors at deployment time. You can make use of and combine the various built-in Terraform functions to achieve the result you want and display a meaningful error message.

- With validation in Terraform, you can specify the error message.

- Now, create folder to run terrafom config file.

- Create a file named `validation.tf` for the configuration code and copy and paste the following content. 

```bash
cd ..
mkdir validation && cd validation && touch validation.tf
```

```go
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
```

- Run the following commands.

```bash
terraform init
terraform plan
terraform plan -var "instancetype=t2.large"
# Invalid instance type.
terraform plan -var "myami=026b57f3c383c2eec"
# The image id is not starting with "ami-".
terraform plan -var "department=CYBER"
# Resource tag must not have this prefix.
```

- Becouse of the ``validation`` in terraform configuration file, we take the error messages.
