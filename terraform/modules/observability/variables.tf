variable "cluster_name" {
  description = "Name of the EKS cluster receiving the add-on"
  type        = string
}

variable "node_group_dependency" {
  description = "Node group name, passed only to force the add-on to install after nodes exist"
  type        = string
}

variable "control_plane_log_retention_days" {
  description = "How long CloudWatch keeps EKS control plane logs. Audit logs are chatty, so this is deliberately short."
  type        = number
  default     = 7
}
