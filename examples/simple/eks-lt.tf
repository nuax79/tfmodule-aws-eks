# DEFINE Launch_Template
module "launch_template" {

  context = var.context
  security_group_ids    = [ module.eks.worker_security_group_id ]

  launch_templates = {

    sonarqube = {
      instance_type         = "t3.large"
      ami_id                = data.aws_ami.dxcd.id
      user_data             = data.template_file.dxci.rendered
      key_name              = var.key_name
    }

    gitlab = {
      instance_type         = "t3.large"
      ami_id                = data.aws_ami.dxcd.id
      user_data             = data.template_file.dxcd.rendered
      key_name              = var.key_name
    }

  }

  depends_on = [ aws_iam_role.admin, aws_iam_role.viewer ]

}