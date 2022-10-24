resource "aws_instance" "web" {
  ami = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  # No of Instance
  count = 1
  # Attach SG to EC2
  security_groups = [aws_security_group.Security_Group.name]

  # EC2 Instance Name
  tags = {
    Name = "EC2-VM-01"
  }
}
  # Attach Key-Pair
resource "aws_key_pair" "ec2_key" {
    key_name = "ec2_key"
    public_key = tls_private_key.rsa.public_key_openssh
  }
  # Key-Pair Algorithm
resource "tls_private_key" "rsa" {
    algorithm = "RSA" 
    rsa_bits = 4096
  }
  # Private key store as ec2_key in local directory
resource "local_file" "ec2_key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "ec2_key"
}

# Add security group
resource "aws_security_group" "Security_Group" {
  name        = "Security Group for EC2"
  description = "Security Group for EC2"
  vpc_id      = "vpc-0399770422b3b69c9"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # "-1" Meant all the traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Security_Group"
  }
}
