provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "db-sg" {
    name = "dg-sg"
    ingress {
        to_port = 3306
        from_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_db_instance" "mysql" {
  identifier = "mysql"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t4g.micro"
  allocated_storage = 30
  db_name = "mysqldb"
  username = "admin"
  password = "MySecurePass123!"

  publicly_accessible = true
  skip_final_snapshot = true

}