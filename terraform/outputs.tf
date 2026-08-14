# ------------------------------------------------------------------
# Root outputs.
#
# EXACTLY the five values the assessment specifies, and nothing more.
#
# "terraform output -json" is committed to this public repository as
# grading.json, and it prints values in full even when marked
# sensitive. Adding an output here that touches a credential would
# publish it permanently. Values needed at deploy time but not
# graded (database endpoints, the carts role ARN, SSM parameter
# names) are read from module state instead, never promoted here.
# ------------------------------------------------------------------

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region hosting all resources"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the Bedrock VPC"
  value       = module.networking.vpc_id
}

output "assets_bucket_name" {
  description = "Name of the assets bucket that triggers the processor Lambda"
  value       = module.serverless.assets_bucket_name
}
