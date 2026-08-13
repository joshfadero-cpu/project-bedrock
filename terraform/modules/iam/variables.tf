variable "cluster_name" {
  description = "Name of the EKS cluster, needed for the access entry"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace the developer user may view. Fixed by the assessment."
  type        = string
}

variable "dev_user_name" {
  description = "Name of the read-only developer IAM user. Fixed by the assessment."
  type        = string
}

variable "assets_bucket_arn" {
  description = "ARN of the assets bucket, for the developer's scoped PutObject grant"
  type        = string
}

variable "carts_table_arn" {
  description = "ARN of the DynamoDB carts table"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the cluster OIDC provider, without the https prefix"
  type        = string
}

variable "carts_service_account" {
  description = "Name of the Kubernetes service account the carts pod runs as"
  type        = string
}
