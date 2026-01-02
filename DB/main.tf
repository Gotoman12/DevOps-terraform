provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "mysql" {
    engine              = "mysql"
    allocated_storage   = 10
    instance_class      = "db.t2.micro"
    db_name                = "database-1"
    username            = "admin"
    password            = "${var.db_password}"
    skip_final_snapshot = true
}