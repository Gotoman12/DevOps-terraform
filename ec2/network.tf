provider "aws" {
    region = "us-east-1"
}
resource "aws_security_group" "ec2-sg" {
    vpc_id = aws_vpc.test-vpc.id
    name = "ec2-sg"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }
  tags = {
    Name = "ec2-sg"
  }
}