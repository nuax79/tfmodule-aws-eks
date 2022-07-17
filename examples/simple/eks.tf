module "eks" {
  # source                      = "git::https://github.com/bsp-dx/tfmodule-aws-eks.git"
  source                        = "../../"

  context                       = var.context

  # aws-auth 설정
  iam_admin_role_arn            = aws_iam_role.admin.arn
  iam_viewer_role_arn           = aws_iam_role.admin.arn

  # for EKS
  create_eks                            = true
  cluster_version                       = "1.19"
  cluster_service_ipv4_cidr             = "10.10.0.0/16"
  cluster_endpoint_public_access        = true
  cluster_endpoint_public_access_cidrs  = ["0.0.0.0/0"]
  cluster_endpoint_private_access       = true
  cluster_endpoint_private_access_cidrs = ["0.0.0.0/0"]

  vpc_id                                = module.vpc.vpc_id
  subnets                               = module.vpc.private_subnets

  map_users = [
    {
      userarn  = "arn:aws:iam::827519537363:user/terra"
      username = "terra"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::827519537363:user/seonbo.shim@bespinglobal.com"
      username = "seonbo.shim@bespinglobal.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::827519537363:user/youngkeun.kim@bespinglobal.com"
      username = "youngkeun.kim@bespinglobal.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::827519537363:user/chiseok.song@bespinglobal.com"
      username = "chiseok.song@bespinglobal.com"
      groups   = ["system:masters"]
    }
  ]

  node_groups = {

    dxci = {
      desired_capacity        = 1
      min_capacity            = 1
      max_capacity            = 1
      subnets                 = module.vpc.private_subnets
      iam_role_arn            = module.eks.worker_iam_role_arn
      launch_template_id      = lookup(module.launch_template.ids, "dxci", null)
    }

    dxcd = {
      desired_capacity        = 1
      min_capacity            = 1
      max_capacity            = 1
      subnets                 = module.vpc.private_subnets
      iam_role_arn            = module.eks.worker_iam_role_arn
      launch_template_id      = lookup(module.launch_template.ids, "dxcd", null)
    }

  }

  depends_on = [ aws_iam_role.admin, aws_iam_role.viewer, aws_iam_role.eks_node, module.vpc ]

}
