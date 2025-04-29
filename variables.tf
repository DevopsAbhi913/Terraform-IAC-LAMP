#define a variable for region
variable "rg_name" {
  description = "region name to provision the resource"
  type = string
  default = "ap-south-1"
}
#define a variable for vpc cidr block
variable "vpc_cidr" {
  description = "selecting a cidr block for vpc"
  type = string
  default = "172.20.0.0/16"
}
#define a variable for ami to launch ec2 instance
variable "aws_ami" {
  description = "selecting an ami for ec2 instance"
  type = string
  default = "ami-002f6e91abff6eb96"
}
#define a variable for keypair of  ec2 instance
variable "aws_keypair" {
  description = "selecting a keypair for ec2 instance"
  type = string
  default = "mkey"
}

#define a variable for instance type of  ec2 instance
variable "instance_type" {
  description = "selecting instance type for ec2 instance"
  type = string
  default = "t2.micro"
}