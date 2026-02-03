locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region = get_env("GOOGLE_REGION", "us-central1")
  current_module = path_relative_to_include()
  is_gke_cluster = strcontains(local.current_module, "gke-cluster")
}


remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "backend-terraform15"
    prefix = "${path_relative_to_include()}/terraform.tfstate"
    project = "${local.gcp_project_id}"
    location = "${local.gcp_region}"
  }
}

generate "providers" {
  path      = "providers_generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = "${local.gcp_project_id}"
  region  = "${local.gcp_region}"
}

# 2. Providers K8s y Helm (Solo si NO es el módulo de cluster)
${local.is_gke_cluster ? "# GKE Cluster Module: No K8s providers needed yet" : <<INNER_EOF
provider "kubernetes" {
  host                   = "https://$${var.cluster_endpoint}"
  token                  = var.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://$${var.cluster_endpoint}"
    token                  = var.token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}


# Definimos las variables que Terraform esperará recibir de Terragrunt
variable "cluster_endpoint"       { type = string }
variable "token"           { type = string }
variable "cluster_ca_certificate" { type = string }
INNER_EOF
}
EOF
}