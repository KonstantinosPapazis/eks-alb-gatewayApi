# NGINX Gateway Fabric Implementation for EKS

## Overview

This implementation uses NGINX Gateway Fabric as the Gateway API controller for your EKS cluster. It provides a simple, reliable way to manage ingress traffic using the Kubernetes Gateway API standard.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌──────────────┐
│  GatewayClass   │────▶│     Gateway     │────▶│  HTTPRoute   │
│     (nginx)     │     │ (main-gateway)  │     │              │
└─────────────────┘     └─────────────────┘     └──────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌──────────────┐
│ NGINX Gateway   │     │ Network Load    │     │   Example    │
│   Controller    │     │   Balancer      │     │   Service    │
└─────────────────┘     └─────────────────┘     └──────────────┘
```

## Prerequisites

- EKS cluster is running
- Gateway API CRDs are installed (you've already done this with `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml`)
- kubectl is configured to access your cluster

## What Gets Deployed

1. **NGINX Gateway Fabric** - The Gateway API controller
2. **Network Load Balancer** - AWS NLB for external access
3. **Example Application** - NGINX pods with custom content
4. **Gateway Resources** - GatewayClass, Gateway, and HTTPRoute

## Installation

```bash
# Initialize Terraform (if not already done)
terraform init

# Apply the NGINX Gateway configuration
terraform apply
```

## Verification Steps

### 1. Check NGINX Gateway Controller
```bash
kubectl get pods -n nginx-gateway
```

Expected output:
```
NAME                            READY   STATUS    RESTARTS   AGE
nginx-gateway-xxxxxxxxx-xxxxx   2/2     Running   0          1m
```

### 2. Check Gateway Resources
```bash
kubectl get gatewayclass
kubectl get gateway -n example-app
kubectl get httproute -n example-app
```

### 3. Get the Load Balancer URL
```bash
kubectl get svc -n nginx-gateway nginx-gateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### 4. Test the Application
Once the NLB is provisioned (takes 2-3 minutes), access your application:
```bash
# Get the URL
LB_URL=$(kubectl get svc -n nginx-gateway nginx-gateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test the endpoint
curl http://$LB_URL
```

## Troubleshooting

### Gateway Not Ready
```bash
kubectl describe gateway -n example-app main-gateway
```

### NGINX Gateway Logs
```bash
kubectl logs -n nginx-gateway deployment/nginx-gateway -f
```

### HTTPRoute Issues
```bash
kubectl describe httproute -n example-app example-route
```

## Adding More Routes

To add more applications and routes:

```hcl
# New HTTPRoute
resource "kubernetes_manifest" "new_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "api-route"
      namespace = "example-app"
    }
    spec = {
      parentRefs = [
        {
          name = "main-gateway"
        }
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/api"
              }
            }
          ]
          backendRefs = [
            {
              name = "api-service"
              port = 8080
            }
          ]
        }
      ]
    }
  }
}
```

## Advanced Features

### Path-based Routing
```yaml
matches:
- path:
    type: PathPrefix
    value: /api
- path:
    type: Exact
    value: /health
```

### Header-based Routing
```yaml
matches:
- headers:
  - name: X-Version
    value: v2
```

### Traffic Splitting
```yaml
backendRefs:
- name: service-v1
  port: 80
  weight: 80
- name: service-v2
  port: 80
  weight: 20
```

## Cost Considerations

- **Network Load Balancer**: ~$0.0225 per hour + data processing charges
- **No additional controller costs** (NGINX Gateway Fabric is open source)

## Clean Up

To remove all resources:
```bash
terraform destroy
```

## Benefits of NGINX Gateway Fabric

1. **Simple**: No complex AWS integrations required
2. **Reliable**: Battle-tested NGINX technology
3. **Fast**: High-performance data plane
4. **Standard**: Full Gateway API compliance
5. **Cost-effective**: Only pay for the NLB

## Next Steps

1. Add HTTPS support with TLS certificates
2. Configure custom domains
3. Implement rate limiting
4. Add authentication/authorization
5. Set up monitoring and observability

## Resources

- [NGINX Gateway Fabric Documentation](https://docs.nginx.com/nginx-gateway-fabric/)
- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [NGINX Gateway Fabric GitHub](https://github.com/nginxinc/nginx-gateway-fabric) 