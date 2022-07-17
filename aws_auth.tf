locals {
  map_roles = [
    {
      rolearn  = var.iam_admin_role_arn
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = var.iam_viewer_role_arn
      username = "viewers"
      groups   = ["system:viewers"]
    }]
}

/**
 * AWS IAM authentication 으로 (admin, viewer 등 기본 사용자 그룹을 생성) ectd 에 들어갈 configmap 정보를 구성 합니다.
 * @see ./docs/HELP.md
 */
resource "kubernetes_config_map" "aws_auth" {
  count      = var.create_eks ? 1 : 0
  depends_on = [null_resource.wait_for_cluster[0]]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "Toolchain"
        "app.kubernetes.io/component" = "AWS-Auth"
        "app.kubernetes.io/version" = "1.0.0"
        "terraform.io/module" = "terraform-aws-modules.eks.aws"
      },
      var.aws_auth_additional_labels
    )
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        local.map_roles,
        var.map_roles,
      ))
    )
    mapUsers    = yamlencode(var.map_users)
    mapAccounts = yamlencode(var.map_accounts)
  }
}
