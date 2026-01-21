provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.gke_state.outputs.endpoint}"
  cluster_ca_certificate = base64decode(data.terraform_remote_state.gke_state.outputs.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}