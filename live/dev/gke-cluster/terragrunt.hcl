locals {
  # Leemos la variable de entorno. 
  # El segundo valor es un "fallback" por si la variable no existe (útil para pruebas locales)
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  # Apunta a tu módulo local (o un repo git con doble //)
  source = "../../../modules//gke-cluster"
}


inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "us-central1"
  cluster_name = "inteligencia-artificial"
  environment =  "dev"
}