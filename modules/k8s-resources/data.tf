data "terraform_remote_state" "gke_state" {
  backend = "gcs"
  config = {
    bucket = "backend-terraform15"
    prefix = "gke-cluster"
  }
}

data "google_client_config" "default" {}