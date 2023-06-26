terraform {
  source = "/home/ec2-user/lesson/terraform-modules/modules"
}

inputs = {
  environment = "PROD"
  vpc_cidr_block = "10.2.0.0/16"
  public_subnet_cidr = "10.2.1.0/24"
  private_subnet_cidr = "10.2.2.0/24"
  mykey = "latif"
  instancetype = "t3a.medium"
  myami = "ami-0557a15b87f6559cf"
  num = 2
}