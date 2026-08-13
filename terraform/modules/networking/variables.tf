variable "vpc_name" {
  description = "Name tag for the VPC. Fixed by the assessment specification."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per availability zone"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets, one per availability zone"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name, used in the kubernetes.io subnet tags"
  type        = string
}
