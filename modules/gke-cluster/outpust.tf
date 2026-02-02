output "endpoint" {
  value = google_container_cluster.gke_cluster.endpoint 
}

output "host" {
  description = "El endpoint del cluster GKE"
  sensitive   = true
  value       = google_container_cluster.gke_cluster.endpoint 
}

output "cluster_ca_certificate" {
  description = "Certificado CA público del cluster"
  sensitive   = true
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
}

output "token" {
  description = "Token de acceso (requiere data google_client_config)"
  sensitive   = true
  value       = data.google_client_config.default.access_token
}