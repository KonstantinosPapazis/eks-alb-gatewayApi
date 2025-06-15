terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    null = {
      source  = "hashicorp/null"
    }
    time = {
      source  = "hashicorp/time"
    }
  }
} 