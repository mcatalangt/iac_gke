locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region = get_env("GOOGLE_REGION", "us-central1")
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

provider "google" {
  project = "${local.gcp_project_id}"
  region  = "${local.gcp_region}"
}

provider "kubernetes" {
  host                   = "https://${dependency.gke.outputs.host}"
  token                  = "${dependency.gke.outputs.token}"
  cluster_ca_certificate = base64decode("${dependency.gke.outputs.cluster_ca_certificate}")
}

provider "helm" {
  kubernetes {
    host                   = "https://${dependency.gke.outputs.host}"
    token                  = "${dependency.gke.outputs.token}"
    cluster_ca_certificate = base64decode("${dependency.gke.outputs.cluster_ca_certificate}")
  }
}
EOF
}
