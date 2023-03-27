provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
    source = "devopswizard/docker-instance/aws"
    key_name = "latif"
}