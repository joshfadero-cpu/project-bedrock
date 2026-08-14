# Project Bedrock - Root Configuration
# AltSchool of Engineering, Tinyuka 2025, Third Semester Capstone

terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state, shared between this machine and the CI/CD pipeline.
  # The bucket is the one manually created resource (bootstrap exception).
  # Native S3 locking via use_lockfile requires Terraform 1.11 or later,
  # which is why no DynamoDB lock table exists in this project.
  backend "s3" {
    bucket       = "bedrock-tfstate-joshfadero"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "tinyuka-2025-capstone"
      ManagedBy = "terraform"
    }
  }
}

# ------------------------------------------------------------------
# Networking: VPC, subnets, IGW, NAT Gateway, route tables
# ------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  vpc_name             = "project-bedrock-vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
}

# ------------------------------------------------------------------
# EKS: cluster, OIDC provider, managed node group
# ------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
}

# ------------------------------------------------------------------
# Serverless: assets bucket, asset processor Lambda, S3 trigger
# ------------------------------------------------------------------
module "serverless" {
  source = "./modules/serverless"

  assets_bucket_name   = "bedrock-assets-${var.student_id}"
  lambda_function_name = "bedrock-asset-processor"
  lambda_source_dir    = "${path.root}/../lambda"
}

# ------------------------------------------------------------------
# Data layer: RDS MySQL, RDS PostgreSQL, DynamoDB
# ------------------------------------------------------------------
module "data" {
  source = "./modules/data"

  name_prefix               = var.project_name
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  cluster_security_group_id = module.eks.cluster_security_group_id
  db_instance_class         = var.db_instance_class
  backup_retention_days     = var.db_backup_retention_days
}

# ------------------------------------------------------------------
# IAM: read-only developer user, cluster access entry, carts IRSA role
# ------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  cluster_name          = module.eks.cluster_name
  namespace             = "retail-app"
  dev_user_name         = "bedrock-dev-view"
  assets_bucket_arn     = module.serverless.assets_bucket_arn
  carts_table_arn       = module.data.carts_table_arn
  oidc_provider_arn     = module.eks.oidc_provider_arn
  oidc_provider_url     = module.eks.oidc_provider_url
  carts_service_account = "carts"
}

# ------------------------------------------------------------------
# Observability: container log collection and log retention
# ------------------------------------------------------------------
module "observability" {
  source = "./modules/observability"

  cluster_name          = module.eks.cluster_name
  node_group_dependency = module.eks.node_group_name
}
