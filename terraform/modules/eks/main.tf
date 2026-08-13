# ------------------------------------------------------------------
# EKS cluster, OIDC provider and managed node group
# ------------------------------------------------------------------

resource "aws_eks_cluster" "bedrock" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  # Access entries only. The legacy aws-auth ConfigMap is not used.
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # All five control plane log types, sent to CloudWatch Logs.
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

# ---------------- OIDC provider for IRSA ----------------
# Lets a Kubernetes service account assume an IAM role, so the carts
# pod reaches DynamoDB with no access key stored anywhere.

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.bedrock.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  url             = aws_eks_cluster.bedrock.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
}

# ---------------- Managed node group ----------------

resource "aws_eks_node_group" "bedrock" {
  cluster_name    = aws_eks_cluster.bedrock.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
    aws_iam_role_policy_attachment.node_cloudwatch_policy
  ]
}
