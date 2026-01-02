provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example" {
  identifier          = "mysql-db"
  engine              = "mysql"
  engine_version      = "8.0"
  allocated_storage   = 20
  instance_class      = "db.t4g.micro"

  db_name             = "database1"
  username            = "admin"
  password            = var.db_password

  skip_final_snapshot = true
  publicly_accessible = true
}
