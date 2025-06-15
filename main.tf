locals {
  name   = "eks-deployment" #"ex-${basename(path.cwd)}"
  region = "us-east-1" #"eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Case    = local.name
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "git::https://github.com/KonstantinosPapazis/my_aws_vpc_module.git"

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
  # public_subnet_names omitted to show default name generation for all three subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true


  tags = local.tags
}
