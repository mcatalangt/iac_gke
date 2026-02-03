
locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region = get_env("GOOGLE_REGION", "us-central1")
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//k8s-resources"
}

dependency "gke" {
  config_path = "../gke-cluster"

  mock_outputs = {
    host                   = "https://1.2.3.4"
    cluster_ca_certificate = "dGVzdA=="
    token                  = "mock-token"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "plan-all"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

#generate "provider_k8s" {
#  path      = "provider_k8s.tf"
#  if_exists = "overwrite_terragrunt"
#  contents  = <<EOF
#provider "kubernetes" {
#  host                   = "https://${dependency.gke.outputs.host}"
#  token                  = "${dependency.gke.outputs.token}"
#  cluster_ca_certificate = base64decode("${dependency.gke.outputs.cluster_ca_certificate}")
#}
#EOF
#}

inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "${local.gcp_region}"
  cluster_name = "ia"
  environment =  "dev"
  cluster_endpoint       = dependency.gke.outputs.host
  cluster_ca_certificate = dependency.gke.outputs.cluster_ca_certificate
  access_token           = dependency.gke.outputs.token
  
}