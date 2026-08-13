output "dev_user_name" {
  description = "Name of the read-only developer IAM user"
  value       = aws_iam_user.dev_view.name
}

output "dev_user_arn" {
  description = "ARN of the read-only developer IAM user"
  value       = aws_iam_user.dev_view.arn
}

output "carts_role_arn" {
  description = "ARN of the carts IRSA role, annotated onto the carts service account"
  value       = aws_iam_role.carts.arn
}
