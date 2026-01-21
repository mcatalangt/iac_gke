include "root" {
  path = find_in_parent_folders()
}

terraform {
  # Apunta a tu módulo local (o un repo git con doble //)
  source = "../../../modules//gke-cluster"
}

inputs = {
  cluster_name = "data-reliability-prod"
  node_count   = 1
  machine_type = "e2-standard-4"
}