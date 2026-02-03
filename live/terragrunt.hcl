# Archivo: /terragrunt.hcl (EN LA RAÍZ)

locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region     = get_env("GOOGLE_REGION", "us-central1")
  current_module = path_relative_to_include()
  is_gke_cluster = strcontains(local.current_module, "gke-cluster")
}

# 1. Configuración de Terragrunt (ESTO VA FUERA DE LOS GENERATE)
# Esto le dice a Terragrunt: "Cuando hagas init, usa siempre -upgrade"
terraform {
  extra_arguments "force_upgrade" {
    commands  = ["init"]
    arguments = ["-upgrade"]
  }
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket   = "backend-terraform15"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "${local.gcp_project_id}"
    location = "${local.gcp_region}"
  }
}

# 2. Generar archivo de VERSIONES (Bloque Independiente)
generate "versions" {
  path      = "versions_override.tf"
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
EOF
}

# 3. Generar archivo de PROVIDERS (Bloque Independiente)
generate "providers" {
  path      = "providers_v2.tf"
  if_exists = "overwrite_terragrunt"
  
  contents  = <<EOF
provider "google" {
  project = "${local.gcp_project_id}"
  region  = "${local.gcp_region}"
}

${local.is_gke_cluster ? "# GKE Cluster: No providers needed" : <<INNER
provider "kubernetes" {
  host                   = "https://$${var.cluster_endpoint}"
  token                  = var.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://$${var.cluster_endpoint}"
    token                  = var.access_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

# Variables necesarias (Deben llamarse igual que en tus inputs)
variable "cluster_endpoint"       { type = string }
variable "access_token"           { type = string }
variable "cluster_ca_certificate" { type = string }
INNER
}
EOF
}