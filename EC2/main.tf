resource "aws_instance" "web" {
  ami = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  # No of Instance
  count = 2

  tags = {
    # EC2 Instance Name
    Name = "EC2-VM-01"
  }

}
