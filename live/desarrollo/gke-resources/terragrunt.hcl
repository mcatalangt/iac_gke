
locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region = get_env("GOOGLE_REGION", "us-central1")
  deploy_stack = get_env("TF_VAR_deploy_stack", "k8s-base")
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//gke-resources"
}

dependency "gke" {
  config_path = "../gke-base"

  mock_outputs = {
    cluster_endpoint       = "https://1.2.3.4"
    cluster_ca_certificate = "dGVzdA=ffff="
    token                  = "mock-tokendfffffffff"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "plan-all"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "${local.gcp_region}"
  cluster_name = "${local.deploy_stack}"
  environment =  "dev"
  cluster_endpoint       = dependency.gke.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.gke.outputs.cluster_ca_certificate
  token                  = dependency.gke.outputs.token

}