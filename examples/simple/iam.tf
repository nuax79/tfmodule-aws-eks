# MFA 활성화 정책 생성
resource "aws_iam_policy" "mfa_enabled" {
  name        = var.iam_mfa_policy
  path        = "/"

  policy = templatefile("${path.module}/policy/ForceMFAPolicy.json", {})
}

# EKS Admin Policy
resource "aws_iam_policy" "admin" {
  name        = var.iam_admin_policy
  path        = "/"

  policy = templatefile("${path.module}/policy/AssumeRoleAdminPolicy.json", {
    account_id = data.aws_caller_identity.current.account_id
    role_name  = var.iam_eks_admin_policy
  })
}

# IAM Admin Role for EKS (TO-BE data-source)
resource "aws_iam_role" "admin" {
  name = var.iam_eks_admin_role

  assume_role_policy = templatefile("${path.module}/policy/AssumeRoleEC2Policy.json", {
    account_id = data.aws_caller_identity.current.account_id
  })

  managed_policy_arns = [
    aws_iam_policy.admin.arn,
    aws_iam_policy.mfa_enabled.arn
  ]
}


# IAM Viewer Role for EKS (TO-BE data-source)
resource "aws_iam_role" "viewer" {
  name = var.iam_eks_viewer_role

  assume_role_policy = templatefile("${path.module}/policy/AssumeRoleEC2Policy.json", {
    account_id = data.aws_caller_identity.current.account_id
  })

  managed_policy_arns = [
    aws_iam_policy.viewer.arn,
    aws_iam_policy.mfa_enabled.arn
  ]

}

resource "aws_iam_policy" "viewer" {
  name        = var.iam_eks_viewer_policy
  path        = "/"

  policy = templatefile("${path.module}/policy/AssumeRoleViewerPolicy.json", {
    account_id = data.aws_caller_identity.current.account_id
    role_name = var.iam_eks_viewer_policy
  })
}


# worker node를 위한 EC2 Role / 인스턴스 프로파일
resource "aws_iam_role" "eks_node" {
  name = var.iam_eks_ec2_role
  assume_role_policy = templatefile("${path.module}/policy/AssumeRoleEC2Policy.json", {
    account_id = data.aws_caller_identity.current.account_id
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

resource "aws_iam_instance_profile" "eks_node" {
  name = var.iam_eks_ec2_profile
  role = aws_iam_role.eks_node.name
}