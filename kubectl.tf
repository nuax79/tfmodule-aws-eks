locals {

  kubeconfig_name = var.kubeconfig_name == "" ? "eks_${local.name_prefix}" : var.kubeconfig_name

  kubeconfig = var.create_eks ? templatefile(
    "${path.module}/templates/kubeconfig.tpl",
    {
      kubeconfig_name                   = local.kubeconfig_name
      endpoint                          = coalescelist(aws_eks_cluster.this[*].endpoint, [""])[0]
      cluster_auth_base64               = coalescelist(aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
      aws_authenticator_command         = var.kubeconfig_aws_authenticator_command
      aws_authenticator_command_args    = length(var.kubeconfig_aws_authenticator_command_args) > 0 ? var.kubeconfig_aws_authenticator_command_args : ["token", "-i", coalescelist(aws_eks_cluster.this[*].name, [""])[0]]
      aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
      aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
    }) : ""

}

resource "local_file" "kubeconfig" {
  count                = var.create_eks && var.write_kubeconfig ? 1 : 0
  content              = local.kubeconfig
  filename             = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${local.name_prefix}" : var.config_output_path
  file_permission      = "0644"
  directory_permission = "0755"
}
