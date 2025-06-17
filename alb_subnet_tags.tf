# Tag public subnets
resource "aws_ec2_tag" "public_subnet_elb" {
  for_each = toset(module.vpc.public_subnets)

  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_cluster" {
  for_each = toset(module.vpc.public_subnets)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
  value       = "shared"
}

# Tag private subnets
resource "aws_ec2_tag" "private_subnet_internal_elb" {
  for_each = toset(module.vpc.private_subnets)

  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnet_cluster" {
  for_each = toset(module.vpc.private_subnets)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
  value       = "shared"
}
