variable "name_prefix" {
  description = "Prefix for naming data layer resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the databases live"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group. Must span two AZs."
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group EKS attaches to worker nodes, the only source allowed to reach the databases"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for both instances"
  type        = string
}

variable "backup_retention_days" {
  description = "Automated backup retention in days. Above zero enables backups, required by bonus objective 5.5."
  type        = number
}

variable "catalog_db_name" {
  description = "Database name for the catalog service"
  type        = string
  default     = "catalog"
}

variable "catalog_db_username" {
  description = "Master username for the catalog MySQL instance"
  type        = string
  default     = "catalog"
}

variable "orders_db_name" {
  description = "Database name for the orders service"
  type        = string
  default     = "orders"
}

variable "orders_db_username" {
  description = "Master username for the orders PostgreSQL instance"
  type        = string
  default     = "orders"
}

variable "carts_table_name" {
  description = "Name of the DynamoDB table backing the carts service"
  type        = string
  default     = "bedrock-carts"
}
