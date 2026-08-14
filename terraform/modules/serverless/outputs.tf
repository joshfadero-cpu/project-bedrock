output "assets_bucket_name" {
  description = "Name of the assets bucket"
  value       = aws_s3_bucket.assets.bucket
}

output "assets_bucket_arn" {
  description = "ARN of the assets bucket, used in the developer PutObject grant"
  value       = aws_s3_bucket.assets.arn
}

output "lambda_function_name" {
  description = "Name of the asset processor Lambda"
  value       = aws_lambda_function.asset_processor.function_name
}

output "lambda_log_group" {
  description = "CloudWatch log group where the Lambda writes, for verification"
  value       = aws_cloudwatch_log_group.lambda.name
}
