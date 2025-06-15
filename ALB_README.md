# Application Load Balancer (ALB) for EKS

This configuration sets up a fully functional Application Load Balancer (ALB) for your EKS cluster with the AWS Load Balancer Controller.

## Architecture Overview

```
Internet → ALB → Target Group → EKS Pods
             ↓
        AWS Load Balancer Controller (manages ALB from Kubernetes)
```

## What's Included

### AWS Resources (`alb.tf`)
- **Application Load Balancer**: Internet-facing ALB in public subnets
- **Security Group**: Allows HTTP (80) and HTTPS (443) traffic
- **Target Group**: For routing traffic to EKS services (IP target type)
- **IAM Role & Policy**: For AWS Load Balancer Controller with EKS Pod Identity
- **EKS Pod Identity Association**: Links the service account to IAM role

### Kubernetes Resources (`alb-controller.tf`)
- **AWS Load Balancer Controller**: v2.8.1 deployment
- **Service Account**: For the controller with EKS Pod Identity
- **RBAC**: ClusterRole and ClusterRoleBinding
- **IngressClass**: Default ALB ingress class

### Example Application (`example-app.tf`)
- **Namespace**: `example-app`
- **Deployment**: 3 replicas of Nginx
- **Service**: ClusterIP service
- **Ingress**: Configured to create ALB

## Prerequisites

1. EKS cluster with EKS Pod Identity addon installed
2. VPC with public and private subnets
3. Terraform and kubectl configured

## Deployment Steps

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Plan the Deployment
```bash
terraform plan
```

### 3. Apply the Configuration
```bash
terraform apply
```

### 4. Verify Deployment

Check AWS Load Balancer Controller:
```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

Check example application:
```bash
kubectl get all -n example-app
kubectl get ingress -n example-app
```

### 5. Access Your Application

Get the ALB DNS name:
```bash
terraform output alb_dns_name
# OR
kubectl get ingress -n example-app -o wide
```

Access the application:
```bash
curl http://<alb-dns-name>
```

## How to Use ALB for Your Applications

### Basic Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: my-namespace
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### Common ALB Annotations

| Annotation | Description | Example |
|------------|-------------|---------|
| `alb.ingress.kubernetes.io/scheme` | ALB scheme | `internet-facing` or `internal` |
| `alb.ingress.kubernetes.io/target-type` | Target type | `ip` or `instance` |
| `alb.ingress.kubernetes.io/healthcheck-path` | Health check path | `/health` |
| `alb.ingress.kubernetes.io/listen-ports` | Listener configuration | `[{"HTTP": 80}, {"HTTPS": 443}]` |
| `alb.ingress.kubernetes.io/certificate-arn` | SSL certificate | ACM certificate ARN |
| `alb.ingress.kubernetes.io/group.name` | ALB sharing | Group name for shared ALB |

## Adding HTTPS Support

1. **Request Certificate in ACM**:
```bash
aws acm request-certificate \
  --domain-name "*.yourdomain.com" \
  --validation-method DNS
```

2. **Update Ingress**:
```yaml
annotations:
  alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
  alb.ingress.kubernetes.io/ssl-redirect: '443'
  alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/xxx
```

## Troubleshooting

### Controller Not Starting
```bash
# Check pod status
kubectl describe pod -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check EKS Pod Identity
aws eks describe-pod-identity-association \
  --cluster-name eks-cluster \
  --association-id $(terraform output -raw aws_load_balancer_controller_pod_identity_association_id)
```

### ALB Not Created
```bash
# Check Ingress events
kubectl describe ingress -n example-app

# Check controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### Common Issues

1. **EKS Pod Identity not working**: Ensure the addon is installed
2. **ALB not created**: Check controller logs and IAM permissions
3. **Targets unhealthy**: Verify security groups and health check path

## Security Best Practices

1. **Use HTTPS**: Always use SSL certificates in production
2. **Internal ALB**: Use `internal` scheme for internal services
3. **WAF Integration**: Consider adding AWS WAF for protection
4. **Security Groups**: Restrict source IPs when possible

## Cost Optimization

1. **Share ALBs**: Use `group.name` annotation to share ALBs
2. **Target Type**: Use `ip` for better performance with EKS
3. **Idle Timeout**: Configure appropriate timeout values
4. **Deregistration Delay**: Adjust based on your application

## Monitoring

### CloudWatch Metrics
- ActiveConnectionCount
- HealthyHostCount
- UnHealthyHostCount
- RequestCount
- TargetResponseTime

### Enable Access Logs
```yaml
annotations:
  alb.ingress.kubernetes.io/load-balancer-attributes: |
    access_logs.s3.enabled=true,
    access_logs.s3.bucket=my-alb-logs,
    access_logs.s3.prefix=eks-alb
```

## Clean Up

To remove all resources:
```bash
terraform destroy
```

## Additional Resources

- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [ALB Ingress Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.8/guide/ingress/annotations/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/) 