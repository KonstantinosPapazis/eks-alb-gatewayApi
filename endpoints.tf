locals {
  # Example: Extract region from the VPC ARN
  # The ARN format is arn:aws:ec2:<region>:<account-id>:vpc/<vpc-id>
  #vpc_region = split(":", data.aws_vpc.selected.arn)[3]

  ssm_endpoint_services = {
    "ssm"           = "com.amazonaws.${local.region}.ssm"
    "ec2messages"   = "com.amazonaws.${local.region}.ec2messages"
    "ssmmessages"   = "com.amazonaws.${local.region}.ssmmessages"
  }
}

# Security Group for the VPC Endpoints
# This security group will allow HTTPS traffic from your VPC to the endpoints.
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "ssm-vpc-endpoints-sg"
  description = "Allow HTTPS to SSM VPC Endpoints from within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # Allows traffic from anywhere in the VPC
    # For tighter security, you could restrict this to the CIDR blocks of subnets
    # where your EC2 instances reside, or specific security groups.
  }

  egress {
    description = "Allow all outbound" # Endpoints need to talk back to the service
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-vpc-endpoints-sg"
  }
}

# Create the VPC Endpoints for SSM
resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each            = local.ssm_endpoint_services
  vpc_id              = module.vpc.vpc_id
  service_name        = each.value                 # e.g., com.amazonaws.us-east-1.ssm [[3]]
  vpc_endpoint_type   = "Interface"                # SSM uses Interface endpoints [[3]]
  subnet_ids          = module.vpc.private_subnets # Deploy endpoint network interfaces into these subnets [[1]]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id] # Attach the security group [[1]]
  private_dns_enabled = true                       # Enable private DNS for the endpoint [[3]]

  tags = {
    Name = "vpce-${each.key}" # e.g., vpce-ssm, vpce-ec2messages
  }
}

# Output the DNS names of the VPC endpoints (optional)
output "vpc_endpoint_dns_entries" {
  description = "DNS entries for the SSM VPC Endpoints"
  value = {
    for k, v in aws_vpc_endpoint.ssm_endpoints : k => v.dns_entry
  }
}

output "vpc_endpoint_ids" {
  description = "IDs of the SSM VPC Endpoints"
  value = {
    for k, v in aws_vpc_endpoint.ssm_endpoints : k => v.id
  }
}
