output "address" {
  value = aws_db_instance.mysql.address
}

# Output variable: DB instance port
output "port" {
  value = aws_db_instance.mysql.port
}