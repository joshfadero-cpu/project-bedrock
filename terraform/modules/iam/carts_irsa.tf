# ------------------------------------------------------------------
# IRSA role for the carts service.
#
# The carts pod reaches DynamoDB by assuming this role through a
# signed service account token, so no access key exists anywhere.
# ------------------------------------------------------------------

data "aws_iam_policy_document" "carts_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    # Proves the token was issued for AWS, not some other audience.
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Proves the token belongs to this exact service account in this
    # exact namespace. Without this, any pod in the cluster could
    # assume the role.
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.carts_service_account}"]
    }
  }
}

resource "aws_iam_role" "carts" {
  name               = "project-bedrock-carts-dynamodb-role"
  assume_role_policy = data.aws_iam_policy_document.carts_assume.json
}

data "aws_iam_policy_document" "carts_dynamodb" {
  statement {
    sid    = "CartsTableAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DescribeTable"
    ]

    resources = [
      var.carts_table_arn,
      "${var.carts_table_arn}/index/*"
    ]
  }
}

resource "aws_iam_role_policy" "carts_dynamodb" {
  name   = "carts-dynamodb-access"
  role   = aws_iam_role.carts.name
  policy = data.aws_iam_policy_document.carts_dynamodb.json
}
