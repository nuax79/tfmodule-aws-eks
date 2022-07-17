# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/create-node-role.html
locals {
  worker_role_name     =  format("%sEksWorkerEC2Role", var.context.project)
  worker_profile_name  =  format("%sEksWorkerEC2Profile", var.context.project)
}

# IAM role to use for the EKS node.
resource "aws_iam_role" "workers" {
  count                 = var.create_eks ? 1 : 0
  name                  = local.worker_role_name
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true

  tags = merge(local.tags, {Name = local.worker_role_name})
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  count      = var.create_eks ? 1 : 0
  role       = local.worker_role_name
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"

  depends_on = [aws_iam_role.workers]
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.create_eks ? 1 : 0
  role       = local.worker_role_name
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"

  depends_on = [aws_iam_role.workers]
}

# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/cni-iam-role.html
resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  count      = var.create_eks && var.attach_worker_cni_policy ? 1 : 0
  role       = local.worker_role_name
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"

  depends_on = [aws_iam_role.workers]
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count      = var.create_eks ? length(var.workers_additional_policies) : 0
  role       = local.worker_role_name
  policy_arn = var.workers_additional_policies[count.index]

  depends_on = [aws_iam_role.workers]
}

# EC2 Instance Profile for Worker Node
resource "aws_iam_instance_profile" "workers" {
  count                 = var.create_eks ? 1 : 0
  name                  = local.worker_profile_name
  role                  = aws_iam_role.workers.*.name[0]
}
