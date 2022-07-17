locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
  {
    iam_role_arn            = var.default_iam_role_arn
    # instance_types          = [var.workers_group_defaults["instance_type"]]
    desired_capacity        = var.workers_group_defaults["asg_desired_capacity"]
    min_capacity            = var.workers_group_defaults["asg_min_size"]
    max_capacity            = var.workers_group_defaults["asg_max_size"]
    key_name                = var.workers_group_defaults["key_name"]
    launch_template_id      = var.workers_group_defaults["launch_template_id"]
    launch_template_version = var.workers_group_defaults["launch_template_version"]
    subnets                 = var.workers_group_defaults["subnets"]
  },
  var.node_groups_defaults,
  v,
  ) if var.create_eks }
}

resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_expanded

  cluster_name  = var.cluster_name

  node_group_name = lookup(each.value, "name", join("-", [var.cluster_name, each.key, "node"]))
  node_role_arn = each.value["iam_role_arn"]
  subnet_ids    = each.value["subnets"]

  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }

  ami_type        = lookup(each.value, "ami_type", null)
  disk_size       = lookup(each.value, "disk_size", null)
  instance_types  = lookup(each.value, "instance_types", null)
  release_version = lookup(each.value, "ami_release_version", null)
  capacity_type   = lookup(each.value, "capacity_type", null)

  dynamic "remote_access" {
    for_each = each.value["key_name"] != "" ? [{
      ec2_ssh_key               = each.value["key_name"]
      source_security_group_ids = lookup(each.value, "source_security_group_ids", [])
    }] : []

    content {
      ec2_ssh_key               = remote_access.value["ec2_ssh_key"]
      source_security_group_ids = remote_access.value["source_security_group_ids"]
    }
  }

  dynamic "launch_template" {
    for_each  = each.value["launch_template_id"] != null ? [{
      id      = each.value["launch_template_id"]
      version = each.value["launch_template_version"]
    }] : []

    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  version = lookup(each.value, "version", null)

  labels = merge(
    lookup(var.node_groups_defaults, "k8s_labels", {}),
    lookup(var.node_groups[each.key], "k8s_labels", {})
  )

  tags = merge(var.tags,
          lookup(var.node_groups_defaults, "additional_tags", {}),
          lookup(var.node_groups[each.key], "additional_tags", {}),
          { Name = lookup(each.value, "name", join("-", [var.cluster_name, each.key])) }
        )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  depends_on = [var.ng_depends_on]

}
