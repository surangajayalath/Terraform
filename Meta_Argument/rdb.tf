resource "aws_db_instance" "myrds" {
  engine = "mysql"
  engine_version = "8.0.28"
  allocated_storage = 20
  instance_class = "db.t3.micro"
  storage_type = "gp2"
  identifier = "myrds" # Name of DB
  username = "admin"
  password = "password1997"
  publicly_accessible = true
  # DB snapshot created before the DB instance is deleted
  skip_final_snapshot = true 
  
  tags = {
    "Name" = "myrdsdb"
  }
}
