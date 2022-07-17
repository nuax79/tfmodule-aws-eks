context = {
    aws_credentials_file    = "$HOME/.aws/credentials"
    aws_profile             = "aws-terra"
    aws_region              = "ap-northeast-2"
    region_alias            = "an2"

    project                 = "simple"
    environment             = "Testbed"
    env_alias               = "t"
    owner                   = "test@test.co.kr"
    team_name               = "Devops Transformation"
    team                    = "DX"
    cost_center             = "123456"
    domain                  = "test.shop"
    pri_domain              = "toolchain"
}

iam_mfa_policy              = "simpleMFAPolicy"
iam_admin_policy            = "simpleAdminPolicy"
iam_eks_admin_role          = "simpleEksAdminRole"
iam_eks_admin_policy        = "simpleEksAdminPolicy"
iam_eks_viewer_role         = "simpleEksViewerRole"
iam_eks_viewer_policy       = "simpleEksViewerPolicy"
iam_eks_ec2_role            = "simpleEksEC2Role"
iam_eks_ec2_profile         = "simpleEksEC2Profile"
key_name                    = "test-an2-t-keypair"