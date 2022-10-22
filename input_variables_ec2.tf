terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
variable "instance_name" {
  description = "Value of the Name tag the EC2 instance"
  type = string
  default = "VM-1"
}


# terraform apply -var "instance_name=Linux-VM"
