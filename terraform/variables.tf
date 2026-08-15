# ------------------------------------------------------------------
# Root variables. Defaults are set here for convenience so the
# project runs without a tfvars file. Module variables deliberately
# have no defaults, so a forgotten input fails loudly at the root.
# ------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all resources. Fixed by the assessment specification."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used when naming resources that have no fixed name"
  type        = string
  default     = "project-bedrock"
}

variable "student_id" {
  description = "Student ID, lowercased and hyphenated, used to make the assets bucket globally unique"
  type        = string
  default     = "alt-soe-tin-025-0206"
}

# ---------------- Networking ----------------

variable "vpc_cidr" {
  description = "CIDR block for the Bedrock VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per availability zone"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets, one per availability zone"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# ---------------- EKS ----------------

variable "cluster_name" {
  description = "Name of the EKS cluster. Fixed by the assessment specification."
  type        = string
  default     = "project-bedrock-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version. Oldest version in standard EKS support at time of deployment."
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "Instance type for the managed node group workers"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes, leaving room for autoscaling"
  type        = number
  default     = 4
}

# ---------------- Data layer ----------------

variable "db_instance_class" {
  description = "RDS instance class for both the MySQL and PostgreSQL instances"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_backup_retention_days" {
  description = "Automated backup retention window in days. Must be above zero for bonus objective 5.5."
  type        = number
  default     = 7 # retention in days
}

# ---------------- Cost guardrail ----------------

variable "budget_limit_usd" {
  description = "Monthly budget threshold in USD that triggers an email alert"
  type        = number
  default     = 20
}

variable "budget_alert_email" {
  description = "Email address that receives budget alerts"
  type        = string
  default     = "joshfadero@gmail.com"
}
