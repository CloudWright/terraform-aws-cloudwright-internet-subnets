output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "lambda_egress_security_group" {
  value = aws_security_group.allow_cw_egress.id
}

output "private_route_table_id" {
  value = aws_route_table.private_lambda.id
}