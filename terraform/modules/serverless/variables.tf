variable "assets_bucket_name" {
  description = "Name of the assets bucket. Fixed by the assessment specification."
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the asset processor Lambda. Fixed by the assessment specification."
  type        = string
}

variable "lambda_source_dir" {
  description = "Path to the directory holding the Lambda source"
  type        = string
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps the Lambda's logs"
  type        = number
  default     = 7
}
