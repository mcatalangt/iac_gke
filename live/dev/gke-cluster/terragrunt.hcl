locals {
  gcp_project_id = get_env("GOOGLE_PROJECT_ID", "mi-proyecto-local-fallback")
  gcp_region = get_env("GOOGLE_REGION", "us-central1")
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//gke-cluster"
}


inputs = {
  project_id = "${local.gcp_project_id}"
  region   = "${local.gcp_region}"
  cluster_name = "ia"
  environment =  "dev"
}