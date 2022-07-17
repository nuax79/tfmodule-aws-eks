/**
 * @see https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/control-plane-logs.html
 */
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_eks ? 1 : 0
  name              = "/aws/eks/${local.name_prefix}-eks/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id
  tags = merge(local.tags, {Name = "${local.name_prefix}-cwlog"})
}
