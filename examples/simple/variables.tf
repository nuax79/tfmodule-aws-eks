variable "context" {
  type = object({
    aws_credentials_file    = string # describe a path to locate a credentials from access aws cli
    aws_profile             = string # describe a specifc profile to access a aws cli
    aws_region              = string # describe default region to create a resource from aws
    region_alias            = string # region alias or AWS
    project                 = string # project name is usally account's project name or platform name
    environment             = string # Runtime Environment such as develop, stage, production
    env_alias               = string # Runtime Environment such as develop, stage, production
    owner                   = string # project owner
    team                    = string # Team name of Devops Transformation
    cost_center             = number # Cost Center
  })
}

variable "iam_mfa_policy" {
  description = "IAM MFA Policy"
  type        = string
}

variable "iam_admin_policy" {
  description = "IAM admin Policy"
  type        = string
}

variable "iam_eks_admin_role" {
  description = "IAM Admin Role for EKS Cluster"
  type        = string
}

variable "iam_eks_admin_policy" {
  description = "IAM Admin Policy for EKS Cluster"
  type        = string
}

variable "iam_eks_viewer_role" {
  description = "IAM Viewer Role for EKS Cluster"
  type        = string
}

variable "iam_eks_viewer_policy" {
  description = "IAM Viewer Policy for EKS Cluster"
  type        = string
}

variable "iam_eks_ec2_role" {
  description = "IAM EKS EC2 Role"
  type        = string
}

variable "iam_eks_ec2_profile" {
  description = "IAM EKS EC2 Instance Profile"
  type        = string
}

variable "key_name" {
  description = "key_name"
  type        = string
}

variable "vpc_name" {
  description = "vpc_name"
  type        = string
  default     = null
}


locals {
  name_prefix = format("%s-%s%s", var.context.project, var.context.region_alias, var.context.env_alias)
  cluster_name = format("%s-eks", local.name_prefix)
}
