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