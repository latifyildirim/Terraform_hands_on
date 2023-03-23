
variable "ec2-name" {
  default = "latif-ec2"
}

variable "ec2-ami" {
  default = "ami-0742b4e673072066f"
}

variable "ec2-type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "latif"
}

variable "s3_bucket_name" {
  # default = "latiff-s3-bucket-variable-addwhateveryouwant"
}

variable "num_of_buckets" {
  default = 0

}

variable "users" {
  default = ["aliata", "veli", "kemalettin"]
}

