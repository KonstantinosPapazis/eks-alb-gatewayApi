output "eks" {
  description = "DNS name of the ALB created by the Ingress (may take a few minutes to appear)"
  value       = module.eks
}

output "vpc" {
  description = "VPC outputs"
  value       = module.vpc
}