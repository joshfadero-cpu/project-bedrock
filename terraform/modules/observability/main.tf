# ------------------------------------------------------------------
# Observability.
#
# Control plane logging is enabled on the cluster resource itself in
# the EKS module. This module adds container log collection, which
# needs an agent running on every node, and sets retention so that
# logs do not accumulate indefinitely.
# ------------------------------------------------------------------

# ---------------- Container logs ----------------
# The CloudWatch Observability add-on runs a CloudWatch agent and
# Fluent Bit on each node. Fluent Bit collects container stdout and
# ships it to CloudWatch Logs. The node role already carries
# CloudWatchAgentServerPolicy, which is what permits the write.

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = var.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # The add-on schedules pods, so nodes must exist first. The node
  # group name is passed in purely to create this ordering.
  depends_on = [var.node_group_dependency]
}

# ---------------- Control plane log retention ----------------
# EKS creates this log group itself when control plane logging is
# enabled, so it is adopted here rather than created, purely to set
# retention. Audit logs in particular are high volume and CloudWatch
# charges per gigabyte ingested.

resource "aws_cloudwatch_log_group" "control_plane" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.control_plane_log_retention_days
}
