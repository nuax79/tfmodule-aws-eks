resource "aws_eks_cluster" "this" {
  count                     = var.create_eks ? 1 : 0

  name                      = "${local.name_prefix}-eks"
  version                   = var.cluster_version
  role_arn                  = join("", aws_iam_role.cluster.*.arn)
  enabled_cluster_log_types = local.enabled_cluster_log_types

  vpc_config {
    security_group_ids      = compact([ local.cluster_security_group_id ])
    subnet_ids              = var.subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

  dynamic "encryption_config" {
    for_each = toset(var.cluster_encryption_config)

    content {
      provider {
        key_arn = encryption_config.value["provider_key_arn"]
      }
      resources = encryption_config.value["resources"]
    }
  }

  tags = merge(local.tags, {Name = "${local.name_prefix}-eks"})

  depends_on = [
    aws_security_group_rule.cluster_egress_internet,
    aws_security_group_rule.cluster_https_worker_ingress,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy,
    aws_cloudwatch_log_group.this,
    aws_iam_role.cluster
  ]
}

resource "null_resource" "wait_for_cluster" {
  count = var.create_eks ? 1 : 0

  depends_on = [
    aws_eks_cluster.this,
    aws_security_group_rule.cluster_private_access,
  ]

  provisioner "local-exec" {
    command     = var.wait_for_cluster_cmd
    interpreter = var.wait_for_cluster_interpreter
    environment = {
      ENDPOINT = aws_eks_cluster.this[0].endpoint
    }
  }

}