# Enable IAM Roles for EKS Service-Accounts (IRSA).

# The Root CA Thumbprint for an OpenID Connect Identity Provider is currently
# Being passed as a default value which is the same for all regions and
# Is valid until (Jun 28 17:39:16 2034 GMT).
# https://crt.sh/?q=9E99A48A9960B14926BB7F3B02E22DA2B0AB7280
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
# https://github.com/terraform-providers/terraform-provider-aws/issues/10104
locals {
  sts_principal = "sts.${data.aws_partition.current.dns_suffix}"
}


data "tls_certificate" "certificate" {
  url             = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0]
  depends_on      = [null_resource.wait_for_cluster]
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count           = var.enable_irsa && var.create_eks ? 1 : 0

  client_id_list  = flatten([local.sts_principal, "sts.amazonaws.com"])
  thumbprint_list = coalescelist([data.tls_certificate.certificate.certificates[0].sha1_fingerprint], [var.eks_oidc_root_ca_thumbprint])
  url             = data.tls_certificate.certificate.url
  depends_on      = [null_resource.wait_for_cluster]
}
