locals {
  cluster_role_name     = format("%sEksClusterRole", var.context.project)
}

# IAM role to use for the EKS Cluster.
resource "aws_iam_role" "cluster" {
  count                 = var.create_eks ? 1 : 0
  name                  = local.cluster_role_name
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]

  tags = merge(local.tags, {Name = local.cluster_role_name})
}


/*
 * AmazonEKSVPCResourceController 클러스터와 연결된 클러스터 역할에 Amazon EKS 관리형 정책을 추가합니다.
 * 이 정책은 역할이 네트워크 인터페이스, 프라이빗 IP 주소, 인스턴스와의 연결 및 분리를 관리하도록 허용합니다.
 * https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/security-groups-for-pods.html
 */
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceControllerPolicy" {
  count      = var.create_eks ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSVPCResourceController"
  role       = local.cluster_role_name

  depends_on = [aws_iam_role.cluster]
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count      = var.create_eks ? 1 : 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSClusterPolicy"
  role       = local.cluster_role_name

  depends_on = [aws_iam_role.cluster]
}

# AWSServiceRoleForAmazonEKS

/*
  2020년 4월 16일 이전에 AmazonEKSServicePolicy 필요했으나 더이상 필요하지 않음 (AWSServiceRoleForAmazonEKS 롤에서 AmazonEKSServicePolicy 정책 바인딩)
  https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/service_IAM_role.html
*/
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  count      = 0
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSServicePolicy"
  role       = local.cluster_role_name

  depends_on = [aws_iam_role.cluster]
}


/*
 Adding a policy to cluster IAM role that allow permissions
 required to create AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
*/

data "aws_iam_policy_document" "cluster_elb_creation" {
  count = var.create_eks ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_elb_creation" {
  count       = var.create_eks ? 1 : 0
  name        = "${var.context.project}EksELBCreationRole"
  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
  policy      = data.aws_iam_policy_document.cluster_elb_creation[0].json
  path        = var.iam_path
}

resource "aws_iam_role_policy_attachment" "cluster_elb_creation" {
  count      = var.create_eks ? 1 : 0
  policy_arn = aws_iam_policy.cluster_elb_creation[0].arn
  role       = local.cluster_role_name

  depends_on = [aws_iam_role.cluster]
}