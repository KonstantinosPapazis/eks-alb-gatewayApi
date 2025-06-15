locals {
  kubes = try(
    <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
  name: ${module.eks.cluster_name}
contexts:
- context:
    cluster: ${module.eks.cluster_name}
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${module.eks.cluster_name}"
        - "--region"
        - "${local.region}"
      # Add your role ARN if required
      # - "--role-arn"
      # - "arn:aws:iam::123456789012:role/YourRole"
KUBECONFIG
    ,
    null
  )
}

#output "kubeconfig" {
#  value = local.create ? local.kubes : null
#}

output "kubeconfig" {
  value = local.kubes
}