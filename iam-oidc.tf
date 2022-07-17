locals {
  oidc_role_name    = format("%sEksOidcRole", var.context.project)
  ingress_controller_policy_name  = format("%sIngressControllerPolicy", var.context.project)
  ec2_autoscaler_policy_name  = format("%sEksEC2AutoscalerPolicy", var.context.project)
}

resource "aws_iam_policy" "ingress_controller" {
  count       = var.create_eks ? 1 : 0
  name        = local.ingress_controller_policy_name
  path        = "/"

  policy = file("${path.module}/policy/IngressControllerPolicy.json")
}

resource "aws_iam_policy" "ec2_autoscaler" {
  count       = var.create_eks ? 1 : 0
  name        = local.ec2_autoscaler_policy_name
  description = "IAM EC2 AutoScaler Policy for EKS Cluster "
  path        = "/"

  policy = file("${path.module}/policy/EksEC2AutoscalerPolicy.json")
}

resource "aws_iam_role" "oidc" {
  count         = var.create_eks ? 1 : 0
  name          = local.oidc_role_name

  assume_role_policy = templatefile("${path.module}/policy/AssumeRoleOIDCPolicy.json", {
    oidc_provider_arn = aws_iam_openid_connect_provider.oidc_provider.*.arn[0]
    oidc_provider_id  = element(split("/", aws_iam_openid_connect_provider.oidc_provider.*.arn[0]), 3)
    aws_region  = var.context.aws_region
  })

  managed_policy_arns = [
    aws_iam_policy.ingress_controller.*.arn[0],
    aws_iam_policy.ec2_autoscaler.*.arn[0]
  ]
}
