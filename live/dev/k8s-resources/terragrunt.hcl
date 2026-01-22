
locals {
  # Leemos la variable de entorno. 
  # El segundo valor es un "fallback" por si la variable no existe (útil para pruebas locales)
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//k8s-resources"
}

# DEPENDENCY BLOCK: La magia
dependency "gke" {
  config_path = "../gke-cluster"
  
  # Mock outputs para que el 'plan' inicial no falle si el cluster no existe aún
  mock_outputs = {
    host                   = "https://1.2.3.4"
    cluster_ca_certificate = "b64encoded"
    token                  = "mock-token"
  }
}

inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "us-central1"
  cluster_name = "ia-cluster"
  environment =  "dev"
}