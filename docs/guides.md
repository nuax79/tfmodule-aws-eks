# AAA

## simple 
```hcl
module "simple-eks" {

  source                      = "https://github.com/nuax79/tfmodule-aws-vpc.git"

  project                       = var.project
  env_name                      = var.env_name
  env_alias                     = var.env_alias
  aws_region                    = var.aws_region
  region_alias                  = var.region_alias
  owner                         = var.owner
  team                          = var.team_alias

  # for EKS
  create_eks                    = var.create_eks
  cluster_version               = var.cluster_version

  cluster_service_ipv4_cidr     = "10.10.0.0/16"

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_endpoint_private_access = true
  cluster_endpoint_private_access_cidrs = ["0.0.0.0/0"]

  # aws-auth 설정
  iam_admin_role_arn            = aws_iam_role.admin.arn
  iam_viewer_role_arn           = aws_iam_role.admin.arn

  vpc_id                        = data.aws_vpc.this.id
  subnets                       = data.aws_subnet_ids.subnets.ids

  node_groups = {
    node01 = {
      name              = "node01"
      instance_types    = ["t3.small"]
      desired_capacity  = 1
      min_capacity      = 1
      max_capacity      = 5
      # iam_role_arn      = "" # if not exists default_iam_role_arn
      # key_name          = ""
      # launch_template_id = aws_launch_template.pf_eks_node.id
      # launch_template_version = aws_launch_template.pf_eks_node.latest_version
      subnets           = data.aws_subnet_ids.node01.ids
    }
  }
}

```