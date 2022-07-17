terraform {

  required_version = ">= 0.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.31"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.1.0"
    }
  }

}

provider "aws" {
  region    = var.context.aws_region
  profile   = var.context.aws_profile
  shared_credentials_file = var.context.aws_credentials_file
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                    = data.aws_eks_cluster.this.endpoint
  token                   = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
}


