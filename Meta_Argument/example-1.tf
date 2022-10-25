# This create % instance with same ami & with numbering tag using index value
resource "aws_instance" "web" {
  ami = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"

  # No.of Instance
  count = 1
  # Taking index value for numbering instances
  tags = {
    "Name" = "EC2-VM ${count.index}"
  }

}

