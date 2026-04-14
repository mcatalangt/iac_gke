# Recurso: Clúster GKE
resource "google_container_cluster" "gke_cluster" {
  name                = "${var.cluster_name}-cluster"
  location            = var.region
  initial_node_count  = 1
  deletion_protection = false

  # Configuración del clúster principal
  #enable_autopilot         = false
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Configuración de red
  network    = "default"
  subnetwork = "default"


  # Autorizar acceso al clúster (Ej: GitHub Actions o internet en un clúster de prueba)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  # Deshabilitar el node pool por defecto para gestionarlo por separado
  remove_default_node_pool = true
}

output "debug_cluster_name" {
  value       = var.cluster_name
  description = "Valor actual que está recibiendo cluster_name"
}
# Recurso: Node Pool 1
resource "google_container_node_pool" "primary_nodes" {
  count    = contains(["k8s-base"], var.cluster_name) ? 1 : 0
  name     = "${var.environment}-${var.cluster_name}-nodes-4"
  location = var.region
  cluster  = google_container_cluster.gke_cluster.name

  node_count = 1

  node_config {
    machine_type = "e2-standard-2"
    disk_size_gb = 10

    labels = {
      carga = "general"
    }
  }
}

# Recurso: Node Pool 2
resource "google_container_node_pool" "primary_nodes" {
  count    = contains(["observability", "data"], var.cluster_name) ? 1 : 0
  name     = "${var.environment}-${var.cluster_name}-nodes-4"
  location = var.region
  cluster  = google_container_cluster.gke_cluster.name

  node_count = 2

  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 20

    labels = {
      carga = "general"
    }
  }
}

# Recurso: Node Pool 3 (GPU Spot)
resource "google_container_node_pool" "secondary_nodes" {
  count    = contains(["rag"], var.cluster_name) ? 1 : 0
  name     = "${var.environment}-${var.cluster_name}-gpu-nodes"
  location = var.region
  cluster  = google_container_cluster.gke_cluster.name

  node_count = 1

  # Restrict to a specific zone because GPUs are not available in all zones in a region
  node_locations = ["${var.region}"]

  node_config {
    machine_type = "n1-standard-4"
    disk_size_gb = 50
    disk_type    = "pd-ssd"

    # Enable Spot/Preemptible instances to dramatically reduce costs
    spot = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    # Attach 1x NVIDIA Tesla T4 GPU
    guest_accelerator {
      type  = "nvidia-tesla-t4"
      count = 1
      gpu_driver_installation_config {
        gpu_driver_version = "LATEST"
      }
    }

    labels = {
      carga = "inteligencia-artificial"
    }
  }
}

data "google_client_config" "default" {}
