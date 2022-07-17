locals {
  create_worker_security_group      =  var.create_eks && var.generate_worker_security_group ? true : false
  worker_security_group_name        = "${local.name_prefix}-worker-sg"
  worker_security_group_id          = join("", aws_security_group.worker.*.id)
}

##### Worker Security Group
/**
 *
resource "aws_security_group" "worker" {
  count       = local.create_worker_security_group ? 1 : 0

  name        = local.worker_security_group_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id

  ingress {
    description = "eks cluster security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups  = [ local.cluster_security_group_id ]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = local.worker_security_group_name
      "kubernetes.io/cluster/${local.name_prefix}-eks" = "owned"
    })

}
*/


resource "aws_security_group" "worker" {
  count       = local.create_worker_security_group ? 1 : 0

  name        = local.worker_security_group_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    {
      Name = local.worker_security_group_name
      "kubernetes.io/cluster/${local.name_prefix}-eks" = "owned"
    })
}

resource "aws_security_group_rule" "workers_egress_internet" {
  count                     = local.create_worker_security_group ? 1 : 0

  security_group_id         = local.worker_security_group_id
  description               = "Allow nodes all egress to the Internet."
  protocol                  = "-1"
  cidr_blocks               = ["0.0.0.0/0"]
  from_port                 = 0
  to_port                   = 0
  type                      = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  count                     = local.create_worker_security_group ? 1 : 0

  security_group_id         = local.worker_security_group_id
  source_security_group_id  = local.worker_security_group_id

  description               = "Allow node to communicate with each other."
  protocol                  = "-1"
  from_port                 = 0
  to_port                   = 65535
  type                      = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  count                     = local.create_worker_security_group ? 1 : 0

  security_group_id         = local.worker_security_group_id
  source_security_group_id  = local.cluster_security_group_id

  description               = "Allow workers pods to receive communication from the cluster control plane."
  protocol                  = "tcp"
  from_port                 = var.worker_sg_ingress_from_port
  to_port                   = 65535
  type                      = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  count                     = local.create_worker_security_group ? var.worker_sg_ingress_from_port > 10250 ? 1 : 0 : 0

  security_group_id         = local.worker_security_group_id
  source_security_group_id  = local.cluster_security_group_id

  description               = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                  = "tcp"
  from_port                 = 10250
  to_port                   = 10250
  type                      = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  count                     = local.create_worker_security_group ? 1 : 0

  security_group_id         = local.worker_security_group_id
  source_security_group_id  = local.cluster_security_group_id

  description               = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                  = "tcp"
  from_port                 = 443
  to_port                   = 443
  type                      = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  count                     = local.create_worker_security_group && var.cluster_version >= 1.14 ? 1 : 0
  description               = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol                  = "all"
  security_group_id         = local.worker_security_group_id
  source_security_group_id  = local.cluster_primary_security_group_id
  from_port                 = 0
  to_port                   = 65535
  type                      = "ingress"
}

resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
  count                     = local.create_worker_security_group && var.cluster_version >= 1.14 ? 1 : 0
  description               = "Allow pods running on workers to send communication to cluster primary security group (e.g. Fargate pods)."
  protocol                  = "all"
  security_group_id         = local.cluster_primary_security_group_id
  source_security_group_id  = local.worker_security_group_id
  from_port                 = 0
  to_port                   = 65535
  type                      = "ingress"
  depends_on                = [ aws_security_group.cluster, aws_eks_cluster.this ]
}
