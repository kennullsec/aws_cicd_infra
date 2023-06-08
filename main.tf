provider "aws" {
    region = "us-east-1"  
}

provider "random" {}

resource "random_pet" "name" {}

resource "aws_instance" "web" {

    ami = "ami-05fa00d4c63e32376"
    instance_type =  "t2.micro"
    vpc_security_group_ids = [aws_security_group.web-sg.id]

    tags = {
        Name = random_pet.name.id
    }
  
}

resource "aws_vpc" "main" {

    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "${random_pet.name.id}-vpc"
    }

}

resource "aws_subnet" "public_subnets" {

    count      = length(var.public_subnet_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = element(var.public_subnet_cidrs, count.index)
    availability_zone = element(var.azs, count.index)

    tags = {
      Name = "${random_pet.name.id}-Public-Subnet-${count.index + 1}"
    }

}

resource "aws_subnet" "private_subnets" {

    count      = length(var.private_subnet_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = element(var.private_subnet_cidrs, count.index)
    availability_zone = element(var.azs, count.index)

    tags = {
      Name = "${random_pet.name.id}-Private-Subnet-${count.index + 1}"
    }

}

resource "aws_internet_gateway" "gw" {

    vpc_id = aws_vpc.main.id

    tags = {
      Name = "${random_pet.name.id}-Project-VPC-IG"
    }

}


resource "aws_route_table" "second_rt" {

    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
      Name = "${random_pet.name.id}-2nd-Route-Table"
    }

}

resource "aws_route_table_association" "public_subnet_asso" {

    count = length(var.public_subnet_cidrs)
    subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
    route_table_id = aws_route_table.second_rt.id

}

resource "aws_s3_bucket" "bucket1" {

    bucket = var.bucket_name
    tags = {
      Name = "iac-s3-v1"
    }

}

#resource "aws_s3_bucket_acl" "bucket1" {

#    bucket = var.bucket_name
#    acl = "private"

#}

resource "aws_s3_bucket_versioning" "bucket_versioning" {

    bucket = var.bucket_name
    versioning_configuration {
      status = "Enabled"
    }

}


resource "aws_security_group" "web-sg" {

  name        = "${random_pet.name.id}-sg"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}