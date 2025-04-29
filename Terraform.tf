terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_availability_zones" "available" {}

#configure the aws provider
provider "aws" {
  region = var.rg_name
}
# Create a VPC
resource "aws_vpc" "ahvpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "ahvpc"
  }
}

resource "aws_subnet" "pub_subnets" {
        count = length (data.aws_availability_zones.available.names)
        vpc_id = aws_vpc.ahvpc.id
        cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index * 2)
        availability_zone = data.aws_availability_zones.available.names[count.index]
        tags = {
         Name = "PubSubnet-${count.index}"
         }
        }
resource "aws_subnet" "pri_subnets" {
        count = length (data.aws_availability_zones.available.names)
        vpc_id = aws_vpc.ahvpc.id
        cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index * 2+1)
        availability_zone = data.aws_availability_zones.available.names[count.index]
        tags = {
         Name = "PriSubnet-${count.index}"
         }
        }
resource "aws_internet_gateway" "ahigw" {
        vpc_id = aws_vpc.ahvpc.id
        tags = {
         Name = "ahigw"
         }
        }
resource "aws_route_table" "pubrt" {
        vpc_id = aws_vpc.ahvpc.id
        route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ahigw.id
        }
        tags = {
         Name = "pub-rt"
         }
}

resource "aws_route_table_association" "pubrtbassociation" {
        count = 3
        subnet_id = aws_subnet.pub_subnets[count.index].id
        route_table_id = aws_route_table.pubrt.id
        }
resource "aws_route_table" "prirt" {
        vpc_id = aws_vpc.ahvpc.id
        tags = {
         Name = "pri-rt"
        }
}
resource "aws_route_table_association" "prirtbassociation" {
        count = 3
        subnet_id = aws_subnet.pri_subnets[count.index].id
        route_table_id = aws_route_table.prirt.id
        }
#Creating security groups
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.ahvpc.id
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg"
  }
}

# addig port 80 to allow inbound http traffic
resource "aws_security_group_rule" "httptrf" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.mysg.id
}
# Creating Key pair for Ec2
resource "aws_key_pair" "mkey" {
  key_name   = var.aws_keypair
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrX/oH9jwHR3fv3pFsH8C2LgWiCBKMllcC60+kBpEfHsEtJ7BEHJQfcssW1vfKr+VyztUlGhgU4sSN9S5YpknQnPLey+KNewvswmtzXKx9Fb4viw6jmlVl5cWywZgusMXUllshqWn6s/WN9QYHm/QQ31fAys3u6BleTYonjrvyzWy8P8LrbRbEzxxI+dlDQSZU/jlDU0fUFwyIKgP/J8NhSwfC05+mS0DqbYLQfUZfvUD3UAP5fVfkeI/RA4UHijB8qY+XmO/aL+j8vEXtbP+5NUshxS+u/SuAzHc0h+5kOWkmWTHVBcCL/VAqMgmo21Yd8RYuoTUCsUNH8O3QlPTEbSq6ckBjNN71OgS1n2/j7DkwAp+DuOyU9v3p+zR5Dw+VPuBWQfnvQdQ46mBkZlybEbhk2X5GwfYzjFF4zWwhxeT1zH2i+V3yUjRCGlrLBa3tUdOnbwfgPIjiqNNTZtutN2LHAHFw3zc47X/trqAZFvpY4N3JflyuFgnbqOwCBl0= root@webserver-1"
}
#creating an Instance
resource  "aws_instance" "ahserver" {
  ami = var.aws_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub_subnets[0].id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.mysg.id]
  user_data = file("LAMP.sh")
  key_name = var.aws_keypair
  tags = {
   Name = "ahserver"
   }
 }
output "ec2_instance_ip" {
 value = aws_instance.ahserver.public_ip
 description = "the public ip of the ahserver instance"
}