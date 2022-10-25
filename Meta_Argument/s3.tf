resource "aws_s3_bucket" "mybucket" {
  bucket = "my-tf-test"
  acl = "private"

  # prevent objects from being deleted or overwritten 
  object_lock_configuration {
    object_lock_enabled = "Enabled"
  }

  tags = {
    "Name" = "My Bucket"
  }

  versioning {
    enabled =true
  }

  lifecycle_rule {
    id = "log"
    enabled = true
    prefix = "log/"

    tags = {
      "rule" = "log"
      autoclean = "true"
    }

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }

  }

}
