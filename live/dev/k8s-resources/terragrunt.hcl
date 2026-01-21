include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//k8s-resources"
}

# DEPENDENCY BLOCK: La magia
dependency "gke" {
  config_path = "../gke-cluster"
  
  # Mock outputs para que el 'plan' inicial no falle si el cluster no existe aún
  mock_outputs = {
    host                   = "https://1.2.3.4"
    cluster_ca_certificate = "b64encoded"
    token                  = "mock-token"
  }
}

inputs = {
  # Inyectamos los valores reales del cluster automáticamente
  host                   = dependency.gke.outputs.host
  cluster_ca_certificate = dependency.gke.outputs.cluster_ca_certificate
  token                  = dependency.gke.outputs.token
}