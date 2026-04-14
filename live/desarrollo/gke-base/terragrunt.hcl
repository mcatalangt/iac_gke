locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region = get_env("GOOGLE_REGION", "us-central1")
  deploy_stack = get_env("TF_VAR_deploy_stack", "k8s-base")
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//gke-base"
}


inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "${local.gcp_region}"
  cluster_name = "${local.deploy_stack}"
  environment =  "dev"
}