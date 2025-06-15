################################################################################
# ALB Outputs
################################################################################

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_security_group_id" {
  description = "The ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "alb_target_group_arn" {
  description = "The ARN of the target group for EKS services"
  value       = aws_lb_target_group.eks_services.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "The ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_pod_identity_association_id" {
  description = "The ID of the EKS Pod Identity Association for AWS Load Balancer Controller"
  value       = aws_eks_pod_identity_association.aws_load_balancer_controller.association_id
}

output "example_app_url" {
  description = "URL to access the example application through the ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ingress_alb_dns" {
  description = "DNS name of the ALB created by the Ingress (may take a few minutes to appear)"
  value       = "Check with: kubectl get ingress -n example-app"
} 