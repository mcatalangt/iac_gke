
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

  # ESTO ES LO QUE TE FALTA:
  # Permite usar mocks en el plan
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "plan-all"]
  
  # "shallow": Si el output no está en el estado real, usa el del mock.
  # Sin esto, Terragrunt ve el estado vacío e ignora el mock, causando tu error.
  mock_outputs_merge_strategy_with_state  = "shallow"
}

generate "provider_k8s" {
  path      = "provider_k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "https://${dependency.gke.outputs.host}"
  token                  = "${dependency.gke.outputs.token}"
  cluster_ca_certificate = base64decode("${dependency.gke.outputs.cluster_ca_certificate}")
}
EOF
}

inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "us-central1"
  cluster_name = "inteligencia-artificial"
  environment =  "dev"
  
}