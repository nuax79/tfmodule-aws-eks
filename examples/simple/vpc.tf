# DEFINE VPC
module "vpc" {

  source = "https://github.com/nuax79/tfmodule-aws-vpc.git"

  context = var.context
  cidr    = "172.90.0.0/16"

  # for Route53 API routing for private dns
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs             = ["apne2-az1", "apne2-az3"]

  public_subnets  = ["172.90.1.0/24", "172.90.2.0/24"]
  public_subnet_names  = ["pub-a1", "pub-c1"]
  public_subnet_suffix = "pub"
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name_prefix}-eks" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  enable_nat_gateway = true
  single_nat_gateway = true
  # one_nat_gateway_per_az = true

  private_subnets = [ "172.90.50.0/24", "172.90.51.0/24" ]
  private_subnet_names = [ "toolchain-a1","toolchain-c1" ]
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name_prefix}-eks" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

  /*
  database_subnets =  [ "172.90.90.0/24", "172.90.91.0/24" ]
  database_subnet_names = [ "data-a1", "data-c1"]
  database_subnet_suffix = "data"
  database_subnet_tags = { "grp:Name" = "${local.name_prefix}-data" }
  */

}