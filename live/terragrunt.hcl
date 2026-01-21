# live/terragrunt.hcl

locals {
  # Leemos la variable de entorno. 
  # El segundo valor es un "fallback" por si la variable no existe (útil para pruebas locales)
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
}


remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # Terragrunt creará este bucket automáticamente si no existe
    bucket = "backend-terraform15"
    prefix = "${path_relative_to_include()}/terraform.tfstate"
    project = "${local.gcp_project_id}"
    location = "us-central1"
  }
}

# Genera el provider de google automáticamente también Google
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  project = "${local.gcp_project_id}"
  region  = "us-central1"
}
EOF
}