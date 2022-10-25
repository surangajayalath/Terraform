resource "aws_instance" "web" {
  ami = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"

  # No.of Instance
  count = 1
  # Taking index value for numbering instances
  tags = {
    "Name" = "EC2-VM ${count.index}"
  }
  # Depends on S3
  # If you want to create resource before another one use dependon
  depends_on = [
    aws_s3_bucket.mybucket
  ]

}

resource "aws_s3_bucket" "mybucket" {
  bucket = "sura_bucket"
}

