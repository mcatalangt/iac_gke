# proveedor de Google Cloud
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Backend para almacenar el estado de Terraform 
terraform {
  backend "gcs" {
    bucket = "backend-terraform15"
    prefix = "gke-cluster"
  }
}