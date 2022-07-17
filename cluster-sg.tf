locals {
  cluster_security_group_name        = "${local.name_prefix}-cluster-sg"
  cluster_security_group_id          = join("", aws_security_group.cluster.*.id)
}

##### Cluster Security Group
resource "aws_security_group" "cluster" {
  count       = var.create_eks ? 1 : 0

  name        = local.cluster_security_group_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id

  tags = merge(local.tags, {Name = local.cluster_security_group_name})
}


resource "aws_security_group_rule" "cluster_private_access" {
  count       = var.create_eks && var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access ? 1 : 0

  security_group_id = local.cluster_security_group_id
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.cluster_endpoint_private_access_cidrs
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count             = var.create_eks ? 1 : 0

  security_group_id = local.cluster_security_group_id
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  count                    = var.create_eks ? 1 : 0

  security_group_id        = local.cluster_security_group_id
  source_security_group_id = local.worker_security_group_id
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

