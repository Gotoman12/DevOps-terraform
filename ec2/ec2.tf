provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "webserver" {
    ami = "ami-0b6c6ebed2801a5cb"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ec2-sg]
    tags = {
      Name = "webserver"
    }
}

resource "aws_instance" "appserver" {
    ami = "ami-0b6c6ebed2801a5cb"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ec2-sg]
    key_name = var.aws_instance
    tags = {
      Name = "appserver"
    }
}