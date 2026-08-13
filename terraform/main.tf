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
