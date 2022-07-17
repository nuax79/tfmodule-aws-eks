data "aws_ami" "dxci" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "tag:Name"
    values = [ "dxci-node-ubuntu-18.04*" ]
  }
}

data "template_file" "dxci" {
  template = file("${path.module}/templates/user_data/dxci.sh.tpl")
  vars = {
    cluster_name        = local.cluster_name
    kubelet_extra_args  = "--node-labels=eks-nodegroup=dxci"
  }
}

data "aws_ami" "dxcd" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "tag:Name"
    values = [ "dxcd-node-ubuntu-18.04*" ]
  }
}

data "template_file" "dxcd" {
  template = file("${path.module}/templates/user_data/dxcd.sh.tpl")
  vars = {
    cluster_name          = local.cluster_name
    kubelet_extra_args    = "--node-labels=eks-nodegroup=dxcd"
    bootstrap_extra_args  = ""
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
