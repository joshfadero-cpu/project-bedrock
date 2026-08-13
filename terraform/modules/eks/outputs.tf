output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.bedrock.name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = aws_eks_cluster.bedrock.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.bedrock.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group EKS created for the cluster, worn by the worker nodes"
  value       = aws_eks_cluster.bedrock.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of the worker node IAM role"
  value       = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  description = "ARN of the cluster OIDC provider, used in IRSA trust policies"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "URL of the cluster OIDC provider, without the https prefix"
  value       = replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")
}
