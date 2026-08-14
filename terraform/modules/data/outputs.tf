output "catalog_endpoint" {
  description = "MySQL endpoint for the catalog service, in host:port form as the Helm chart expects"
  value       = aws_db_instance.catalog.endpoint
}

output "catalog_db_name" {
  description = "Database name on the catalog instance"
  value       = aws_db_instance.catalog.db_name
}

output "catalog_db_username" {
  description = "Master username for the catalog instance"
  value       = aws_db_instance.catalog.username
}

output "catalog_password_parameter" {
  description = "SSM parameter name holding the catalog password"
  value       = aws_ssm_parameter.catalog_password.name
}

output "orders_endpoint" {
  description = "PostgreSQL endpoint for the orders service, in host:port form"
  value       = aws_db_instance.orders.endpoint
}

output "orders_db_name" {
  description = "Database name on the orders instance"
  value       = aws_db_instance.orders.db_name
}

output "orders_db_username" {
  description = "Master username for the orders instance"
  value       = aws_db_instance.orders.username
}

output "orders_password_parameter" {
  description = "SSM parameter name holding the orders password"
  value       = aws_ssm_parameter.orders_password.name
}

output "carts_table_name" {
  description = "Name of the DynamoDB carts table"
  value       = aws_dynamodb_table.carts.name
}

output "carts_table_arn" {
  description = "ARN of the DynamoDB carts table, used in the carts IRSA policy"
  value       = aws_dynamodb_table.carts.arn
}
