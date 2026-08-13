# ------------------------------------------------------------------
# bedrock-dev-view: a read-only developer identity.
#
# Three grants, each narrow and separate:
#   1. AWS managed ReadOnlyAccess, for console visibility
#   2. An inline policy allowing PutObject on the assets bucket only
#   3. An EKS access entry scoped to the retail-app namespace, view only
# ------------------------------------------------------------------

resource "aws_iam_user" "dev_view" {
  name = var.dev_user_name
}

# ---------------- 1. Console read-only ----------------

resource "aws_iam_user_policy_attachment" "dev_readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ---------------- 2. Upload to the assets bucket only ----------------

data "aws_iam_policy_document" "dev_assets_put" {
  statement {
    sid       = "PutObjectToAssetsBucketOnly"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.assets_bucket_arn}/*"]
  }
}

resource "aws_iam_user_policy" "dev_assets_put" {
  name   = "bedrock-assets-put-object"
  user   = aws_iam_user.dev_view.name
  policy = data.aws_iam_policy_document.dev_assets_put.json
}

# ---------------- 3. View access inside the cluster ----------------

resource "aws_eks_access_entry" "dev_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.dev_view.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "dev_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.dev_view.arn

  # EKS access policies are global, so both the region and account
  # fields of the ARN are empty. That is the doubled colon after
  # "eks", and writing a single colon there produces a confusing
  # "policyArn could not be found" error.
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [var.namespace]
  }

  depends_on = [aws_eks_access_entry.dev_view]
}
