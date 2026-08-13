variable "cluster_name" {
  description = "Name of the EKS cluster. Fixed by the assessment specification."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the control plane"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs, included so the ALB the controller creates can be placed"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where the worker nodes run"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Instance type for the managed node group workers"
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}
