terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
}

provider "kubernetes" {
  cluster_endpoint       = "https://$${var.cluster_endpoint}"
  token                  = var.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    cluster_endpoint       = "https://$${var.cluster_endpoint}"
    token                  = var.token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}