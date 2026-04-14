terraform {
  source = "../../../modules/observability"
}

# skip si deploy_stack NO es 'observability' NI 'all'
skip = !(get_env("TF_VAR_deploy_stack", "all") == "all" || get_env("TF_VAR_deploy_stack", "all") == "observability")

include "root" {
  path = find_in_parent_folders()
}

dependency "gke" {
  config_path = "../gke-cluster"

  mock_outputs = {
    cluster_endpoint       = "https://1.2.3.4"
    cluster_ca_certificate = "dGVzdA=="
    token                  = "mock-token"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "plan-all"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  cluster_endpoint       = dependency.gke.outputs.cluster_endpoint
  cluster_ca_certificate = dependency.gke.outputs.cluster_ca_certificate
  token                  = dependency.gke.outputs.token
}
