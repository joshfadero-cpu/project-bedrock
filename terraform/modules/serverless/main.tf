# ------------------------------------------------------------------
# Serverless event flow: an upload to the assets bucket triggers the
# asset processor Lambda, which logs the filename to CloudWatch.
# ------------------------------------------------------------------

# ---------------- Assets bucket ----------------

resource "aws_s3_bucket" "assets" {
  bucket        = var.assets_bucket_name
  force_destroy = true

  tags = {
    Name = var.assets_bucket_name
  }
}

# Four switches, each closing a different route by which a bucket can
# accidentally become world readable.
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------- Lambda execution role ----------------

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# The managed basic execution role grants exactly one thing: permission
# to write to CloudWatch Logs. Nothing else is granted, because the
# function reads nothing and writes nothing beyond its own log lines.
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ---------------- Packaging ----------------

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.module}/build/asset-processor.zip"
}

# ---------------- Log group ----------------
# Created explicitly rather than left to Lambda, so that retention is
# set and the group is destroyed with the rest of the stack.

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days
}

# ---------------- The function ----------------

resource "aws_lambda_function" "asset_processor" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "index.handler"
  runtime          = "python3.13"
  timeout          = 10
  memory_size      = 128

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.lambda
  ]
}

# ---------------- The trigger ----------------

resource "aws_lambda_permission" "from_s3" {
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.asset_processor.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.assets.arn
  source_account = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_notification" "assets" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.from_s3]
}
