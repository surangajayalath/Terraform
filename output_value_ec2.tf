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
    Name = "VM-2"
  }
}
output "instance_id" {
  description = "ID of the EC2 Instance"
  value = aws_instance.app_server.id
}
output "instance_public_ip" {
  description = "Public IP of the EC2"
  value = aws_instance.app_server.public_ip
}
