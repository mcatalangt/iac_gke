terraform {
  required_version = ">= 1.5.0" # O la versión que estés usando de OpenTofu/Terraform

  required_providers {
    # El protagonista: Necesario para el recurso helm_release
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }

    # Recomendado: Por si necesitas crear Secrets o ConfigMaps extra
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
    
    # Útil: Si necesitas leer datos de GCP (como data sources)
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }

  }

  
}