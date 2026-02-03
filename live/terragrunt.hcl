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

provider "google" {
  project = "${local.gcp_project_id}"
  region  = "${local.gcp_region}"
}

contents  = local.is_gke_cluster ? "# No providers needed for GKE module" : <<EOF
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
variable "cluster_endpoint" { type = string }
variable "access_token"     { type = string }
variable "cluster_ca_certificate" { type = string }

EOF
}
