# live/terragrunt.hcl
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # Terragrunt creará este bucket automáticamente si no existe
    bucket = "gke-dev-terraform-state"
    prefix = "${path_relative_to_include()}/terraform.tfstate"
    project = "mi-proyecto-gcp-id"
    location = "us-central1"
  }
}

# Genera el provider de google automáticamente también Google
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  project = "mi-proyecto-gcp-id"
  region  = "us-central1"
}
EOF
}